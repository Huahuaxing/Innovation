package app;
import java.io.File;
import java.io.IOException;
import java.util.List;

import com.comsol.model.*;
import com.comsol.model.util.*;

import config.Config;
import config.ConfigLoader;
import crack.CrackData;
import crack.CrackManager;


public class SimulationRunner {

     public static Model run(CrackManager crackManager, int n){

          int crackNum = crackManager.getModelConfig().getCrackNum();
          int groupNum = crackManager.getModelConfig().getGroupNum();
          String crackShape = crackManager.getModelConfig().getCrackShape();          // 裂隙类型，椭圆或多边形
          List<double[]> arList = crackManager.getARList();
          List<double[]> positionList = null;
          List<double[][]> coordinateList = null;
          String exportDir = crackManager.getPathConfig().getExportDir();

          // 创建数据保存目录
          String modelDir = exportDir + String.format("sub_model_%d", n);
          new File(modelDir).mkdirs();

          // 创建COMSOL模型
          Model model = ModelUtil.create("Model");
          // model.modelPath("E:\\OneDrive\\Project\\Innovation");
          // 创建全局变量
          if (crackShape.equals("ellipse")) {
               for (int i = 1; i <= crackNum; i++) {
                    model.param().set("b" + i, arList.get(i - 1)[0] + " [m]");
                    model.param().set("c" + i, arList.get(i - 1)[1] + " [m]");
               }
          }
          model.param().set("p_in", "p_max*kk");
          model.param().set("p_max", "3e7 [Pa]");
          model.param().set("fpeak", "10000 [Hz]");
          model.param().set("t_period", "1/fpeak");
          model.param().set("t_total", "8*t_period");
          model.param().set("t_interval", "1/fpeak/50");
          model.param().set("kk", "2.0");
     
          model.component().create("comp1", true);
          model.component("comp1").geom().create("geom1", 2);
          model.component("comp1").func().create("rn2", "Random");
          model.component("comp1").mesh().create("mesh1");
          model.component("comp1").mesh("mesh1").autoMeshSize(5);
          model.component("comp1").geom("geom1").create("sq1", "Square");
          model.component("comp1").geom("geom1").feature("sq1").set("size", 0.2);
                  
          // 根据裂隙类型创建几何
          if ("ellipse".equalsIgnoreCase(crackShape)) {
               // 椭圆裂隙只需要中心坐标
               if ("read".equalsIgnoreCase(crackManager.getModelConfig().getCrackSource())) {
                    positionList = crackManager.readCrackPosition(n);
               } else {
                    positionList = crackManager.crackPosition();
                    crackManager.saveCrackPosition(positionList, n);
               }
               for (int i = 1; i <= crackNum; i++) {
                    model.component("comp1").geom("geom1").create("e" + i, "Ellipse");
                    model.component("comp1").geom("geom1").feature("e" + i).set("pos", positionList.get(i - 1));
                    model.component("comp1").geom("geom1").feature("e" + i).set("rot", 90);
                    model.component("comp1").geom("geom1").feature("e" + i).set("semiaxes", new String[]{"b" + i, "c" + i});
                    model.component("comp1").geom("geom1").feature("e" + i).set("selresult", true);
                    model.component("comp1").geom("geom1").feature("e" + i).set("selresultshow", "bnd");
                    String inputFeature = (i == 1) ? "sq1" : "dif" + (i - 1);
                    model.component("comp1").geom("geom1").create("dif" + i, "Difference");
                    model.component("comp1").geom("geom1").feature("dif" + i).selection("input").set(inputFeature);
                    model.component("comp1").geom("geom1").feature("dif" + i).selection("input2").set("e" + i);
               }
          } else if ("polygon".equalsIgnoreCase(crackShape)) {
               if ("read".equalsIgnoreCase(crackManager.getModelConfig().getCrackSource())) {
                    positionList = crackManager.readCrackPosition(n);
                    coordinateList = crackManager.readPolCoordinate(n);
               } else {
                    positionList = crackManager.crackPosition();
                    crackManager.saveCrackPosition(positionList, n);
                    coordinateList = crackManager.polCrackCoordinate(positionList);
                    crackManager.savePolCoordinate(coordinateList, n);
               }
               String coordinateDir =
                    "read".equalsIgnoreCase(crackManager.getModelConfig().getCrackSource())
                    ? crackManager.getPathConfig().getReadCoorDir()
                    : crackManager.getPathConfig().getSaveCoorDir();
               for (int i = 1; i <= crackNum; i++) {
                    model.component("comp1").geom("geom1").create("pol" + i, "Polygon");
                    model.component("comp1").geom("geom1").feature("pol" + i).set("source", "file");
                    model.component("comp1").geom("geom1").feature("pol" + i).set("filename", coordinateDir+ "\\data_coordinates_" + n + "\\coordinates" + i + ".txt");
                    model.component("comp1").geom("geom1").feature("pol" + i).set("selresult", true);
                    model.component("comp1").geom("geom1").feature("pol" + i).set("selresultshow", "bnd");
                    String inputFeature = (i == 1) ? "sq1" : "dif" + (i - 1);
                    model.component("comp1").geom("geom1").create("dif" + i, "Difference");
                    model.component("comp1").geom("geom1").feature("dif" + i).selection("input").set(inputFeature);
                    model.component("comp1").geom("geom1").feature("dif" + i).selection("input2").set("pol" + i);
               }
          } else {
               throw new IllegalArgumentException("Unsupported crack shape: " + crackShape);
          }
          model.component("comp1").geom("geom1").run();
          
          // 创建变量var1，var2
          model.component("comp1").variable().create("var1");
          model.component("comp1").variable().create("var2");
          for(int i = 1; i <= crackNum; i++){
               model.component("comp1").variable("var1").set(String.format("area%d", i), String.format("intop%d(-x*solid.nx)", i));
               model.component("comp1").variable("var2").set(String.format("distance%d", i), String.format("aveop%d(y)-aveop%d(y)", 2*i-1, 2*i));
          }
          // 获取裂隙边界序号,奇数取裂隙上面，偶数取下面
          int edgeNum = 0; 
          if(crackShape.equals("ellipse")){
               edgeNum = 4;
          }else if(crackShape.equals("polygon")){
               edgeNum = 40;
          }
          int[][] polEdges = new int[crackNum][edgeNum];
          if(crackShape.equals("ellipse")){
               for(int i = 1; i <= crackNum; i++){
                    polEdges[i-1] = model.component("comp1").selection("geom1_e" + i + "_bnd").entities();
               }
          }else if(crackShape.equals("polygon")){
               for(int i = 1; i <= crackNum; i++){
                    polEdges[i-1] = model.component("comp1").selection("geom1_pol" + i + "_bnd").entities();
               }
          }

          // 创建积分，平均值，接触对
          if(crackShape.equals("ellipse")){
               for(int i = 1; i <= crackNum; i++){
                    model.component("comp1").cpl().create("intop" + i, "Integration");
                    model.component("comp1").cpl("intop" + i).selection().geom("geom1", 1);
                    model.component("comp1").cpl("intop" + i).selection().set(polEdges[i-1]);
                    model.component("comp1").cpl().create("aveop" + (2*i-1), "Average");
                    model.component("comp1").cpl().create("aveop" + (2*i), "Average");
                    model.component("comp1").cpl("aveop" + (2*i-1)).selection().geom("geom1", 1);
                    model.component("comp1").cpl("aveop" + (2*i)).selection().geom("geom1", 1);
                    model.component("comp1").cpl("aveop" + (2*i-1)).selection().set(polEdges[i-1][1], polEdges[i-1][3]);
                    model.component("comp1").cpl("aveop" + (2*i)).selection().set(polEdges[i-1][0], polEdges[i-1][2]);
                    model.component("comp1").pair().create("p" + (2*i-1), "Contact");
                    model.component("comp1").pair().create("p" + (2*i), "Contact");
                    model.component("comp1").pair("p" + (2*i-1)).source().set(polEdges[i-1][0]);
                    model.component("comp1").pair("p" + (2*i-1)).destination().set(polEdges[i-1][1]);
                    model.component("comp1").pair("p" + (2*i)).source().set(polEdges[i-1][2]);
                    model.component("comp1").pair("p" + (2*i)).destination().set(polEdges[i-1][3]);

               }
          }
          if(crackShape.equals("polygon")){
               for(int i = 1; i <= crackNum; i++){
                    model.component("comp1").cpl().create("intop" + i, "Integration");
                    model.component("comp1").cpl("intop" + i).selection().geom("geom1", 1);
                    model.component("comp1").cpl("intop" + i).selection().set(polEdges[i-1]);
                    model.component("comp1").cpl().create("aveop" + (2*i-1), "Average");
                    model.component("comp1").cpl().create("aveop" + (2*i), "Average");
                    model.component("comp1").cpl("aveop" + (2*i-1)).selection().geom("geom1", 1);
                    model.component("comp1").cpl("aveop" + (2*i)).selection().geom("geom1", 1);
                    model.component("comp1").cpl("aveop" + (2*i-1)).selection().set(polEdges[i-1][1], polEdges[i-1][3], polEdges[i-1][5], polEdges[i-1][7], polEdges[i-1][9], polEdges[i-1][11], polEdges[i-1][13], polEdges[i-1][15], polEdges[i-1][17], polEdges[i-1][19], polEdges[i-1][21], polEdges[i-1][23], polEdges[i-1][25], polEdges[i-1][27], polEdges[i-1][29], polEdges[i-1][31], polEdges[i-1][33], polEdges[i-1][35], polEdges[i-1][37], polEdges[i-1][39]);
                    model.component("comp1").cpl("aveop" + (2*i)).selection().set(polEdges[i-1][0], polEdges[i-1][2], polEdges[i-1][4], polEdges[i-1][6], polEdges[i-1][8], polEdges[i-1][10], polEdges[i-1][12], polEdges[i-1][14], polEdges[i-1][16], polEdges[i-1][18], polEdges[i-1][20], polEdges[i-1][22], polEdges[i-1][24], polEdges[i-1][26], polEdges[i-1][28], polEdges[i-1][30], polEdges[i-1][32], polEdges[i-1][34], polEdges[i-1][36], polEdges[i-1][38]);
                    model.component("comp1").pair().create("p" + (2*i-1), "Contact");
                    model.component("comp1").pair().create("p" + (2*i), "Contact");
                    model.component("comp1").pair("p" + (2*i-1)).source().set(polEdges[i-1][0], polEdges[i-1][2], polEdges[i-1][4], polEdges[i-1][6], polEdges[i-1][8], polEdges[i-1][10], polEdges[i-1][12], polEdges[i-1][14], polEdges[i-1][16], polEdges[i-1][18]);
                    model.component("comp1").pair("p" + (2*i-1)).destination().set(polEdges[i-1][1], polEdges[i-1][3], polEdges[i-1][5], polEdges[i-1][7], polEdges[i-1][9], polEdges[i-1][11], polEdges[i-1][13], polEdges[i-1][15], polEdges[i-1][17], polEdges[i-1][19]);
                    model.component("comp1").pair("p" + (2*i)).source().set(polEdges[i-1][20], polEdges[i-1][22], polEdges[i-1][24], polEdges[i-1][26], polEdges[i-1][28], polEdges[i-1][30], polEdges[i-1][32], polEdges[i-1][34], polEdges[i-1][36], polEdges[i-1][38]);
                    model.component("comp1").pair("p" + (2*i)).destination().set(polEdges[i-1][21], polEdges[i-1][23], polEdges[i-1][25], polEdges[i-1][27], polEdges[i-1][29], polEdges[i-1][31], polEdges[i-1][33], polEdges[i-1][35], polEdges[i-1][37], polEdges[i-1][39]);
               }
          }

          // 创建固体物理
          model.component("comp1").physics().create("solid", "SolidMechanics", "geom1");
          model.component("comp1").physics("solid").create("bndl1", "BoundaryLoad", 1);
          model.component("comp1").physics("solid").feature("bndl1").selection().set(3);
          model.component("comp1").physics("solid").create("roll1", "Roller", 1);
          if (crackShape.equals("ellipse")) {
               model.component("comp1").physics("solid").feature("roll1").selection().set(2, 4);
          }
          if(crackShape.equals("polygon")) {
               model.component("comp1").physics("solid").feature("roll1").selection().set(2, 804);
          }
          model.component("comp1").physics("solid").prop("AdvancedSettings").set("GroupNumPhysOdesRd", false);
          model.component("comp1").physics("solid").feature("lemm1").set("IsotropicOption", "CpCs");
          model.component("comp1").physics("solid").feature("lemm1").set("cp_mat", "userdef");
          model.component("comp1").physics("solid").feature("lemm1").set("cp", 2118.9);
          model.component("comp1").physics("solid").feature("lemm1").set("cs_mat", "userdef");
          model.component("comp1").physics("solid").feature("lemm1").set("cs", 1254.7);
          model.component("comp1").physics("solid").feature("lemm1").set("rho_mat", "userdef");
          model.component("comp1").physics("solid").feature("lemm1").set("rho", "2.02e3");
          model.component("comp1").physics("solid").feature("bndl1").set("LoadType", "FollowerPressure");
          model.component("comp1").physics("solid").feature("bndl1").set("FollowerPressure", "p_in");
          model.component("comp1").physics("solid").feature("bndl1").set("weight", "(sqrt((solid.bndl1.x2^2)+(solid.bndl1.x3^2)))<=solid.bndl1.lc");

          model.component("comp1").view("view1").axis().set("xmin", -0.08348365128040314);
          model.component("comp1").view("view1").axis().set("xmax", 0.45775407552719116);
          model.component("comp1").view("view1").axis().set("ymin", -0.04647742956876755);
          model.component("comp1").view("view1").axis().set("ymax", 0.21947236359119415);

          model.study().create("std1");
          model.study("std1").create("stat", "Stationary");
          model.study("std1").feature("stat").set("useparam", true);
          model.study("std1").feature("stat").set("pname", new String[]{"p_in"});
          model.study("std1").feature("stat").set("plistarr", new String[]{"range(0.01,0.01,kk)*p_max"});
          model.study("std1").feature("stat").set("punit", new String[]{"Pa"});

          // 创建求解器
          model.sol().create("sol1");
          model.sol("sol1").study("std1");
          model.sol("sol1").attach("std1");
          model.sol("sol1").create("st1", "StudyStep");
          model.sol("sol1").feature("st1").label("\u7f16\u8bd1\u65b9\u7a0b: \u7a33\u6001");
          model.sol("sol1").create("v1", "Variables");
          model.sol("sol1").feature("v1").label("\u56e0\u53d8\u91cf 1.1");
          model.sol("sol1").feature("v1").set("clistctrl", new String[]{"p1"});
          model.sol("sol1").feature("v1").set("cname", new String[]{"p_in"});
          model.sol("sol1").feature("v1").set("clist", new String[]{"range(0.01,0.01,kk)*p_max"});
          model.sol("sol1").feature("v1").feature("comp1_u").set("scalemethod", "manual");
          model.sol("sol1").feature("v1").feature("comp1_u").set("scaleval", "1e-2*0.28284271247461906");
          model.sol("sol1").create("s1", "Stationary");
          model.sol("sol1").feature("s1").label("\u7a33\u6001\u6c42\u89e3\u5668 1.1");
          model.sol("sol1").feature("s1").set("probesel", "none");
          model.sol("sol1").feature("s1").feature("dDef").label("\u76f4\u63a5 1");
          model.sol("sol1").feature("s1").feature("aDef").label("\u9ad8\u7ea7 1");
          model.sol("sol1").feature("s1").feature("aDef").set("cachepattern", true);
          model.sol("sol1").feature("s1").create("p1", "Parametric");
          model.sol("sol1").feature("s1").feature("p1").label("\u53c2\u6570\u5316 1.1");
          model.sol("sol1").feature("s1").feature("p1").set("pname", new String[]{"p_in"});
          model.sol("sol1").feature("s1").feature("p1").set("plistarr", new String[]{"range(0.01,0.01,kk)*p_max"});
          model.sol("sol1").feature("s1").feature("p1").set("punit", new String[]{"Pa"});
          model.sol("sol1").feature("s1").feature("p1").set("porder", "constant");
          // model.sol("sol1").feature("s1").feature("p1").set("uselsqdata", false);
          model.sol("sol1").feature("s1").create("fc1", "FullyCoupled");
          model.sol("sol1").feature("s1").feature().remove("fcDef");
          model.sol("sol1").feature("s1").feature("fc1").label("\u5168\u8026\u5408 1.1");
          model.sol("sol1").feature("s1").feature("fc1").set("dtech", "ddog");
          model.sol("sol1").runAll();

          // // 创建2D绘图
          // model.result().create("pg1", "PlotGroupNum2D");
          // model.result("pg1").label("\u5e94\u529b (solid)");
          // model.result("pg1").set("frametype", "spatial");
          // model.result("pg1").create("surf1", "Surface");
          // model.result("pg1").feature("surf1")
          //      .set("const", new String[][]{{"solid.refpntx", "0", "\u529b\u77e9\u8ba1\u7b97\u53c2\u8003\u70b9\uff0cx \u5750\u6807"}, {"solid.refpnty", "0", "\u529b\u77e9\u8ba1\u7b97\u53c2\u8003\u70b9\uff0cy \u5750\u6807"}, {"solid.refpntz", "0", "\u529b\u77e9\u8ba1\u7b97\u53c2\u8003\u70b9\uff0cz \u5750\u6807"}});
          // model.result("pg1").feature("surf1").set("colortable", "Prism");
          // model.result("pg1").feature("surf1").set("threshold", "manual");
          // model.result("pg1").feature("surf1").set("thresholdvalue", 0.2);
          // model.result("pg1").feature("surf1").set("resolution", "normal");
          // model.result("pg1").feature("surf1").set("expr", "solid.mises");
          // model.result("pg1").feature("surf1").create("def", "Deform");
          // model.result("pg1").feature("surf1").feature("def").set("scaleactive", true);
          
          // 创建二维截点
          for (int i = 1; i <= 2 * crackNum; i++) {
               int crackIndex = (i - 1) / 2;
               double centerX = positionList.get(crackIndex)[0];
               double centerY = positionList.get(crackIndex)[1];
               double c0 = arList.get(crackIndex)[1];
               double leftX = centerX - c0;
               double rightX = centerX + c0;
               double interval = (rightX - leftX) / 20.0;
               double pointY = centerY;
               if (i % 2 != 0) {
                    pointY += 0.0001;
               } else {
                    pointY -= 0.0001;
               }
               model.result().dataset().create("cpt" + i, "CutPoint2D");
               model.result().dataset("cpt" + i).set("pointx", "range(" + leftX + "," + interval + "," + rightX + ")");
               model.result().dataset("cpt" + i).set("pointy", pointY);
               model.result().dataset("cpt" + i).set("snapping", "boundary");
               model.result().dataset("cpt" + i).set("pointvar", "cpt" + i + "n");
          }

          // 要导出的数据一共有三个条目，裂隙面积（porocity）、二维截点坐标（distance）和二维截点y应力（syy），一共81个表格
          // 创建全局计算1表格
          model.result().table().create("tbl" + 1, "Table");
          model.result().table("tbl" + 1).comments("全局计算 " + 1);
          // 创建二维截点坐标表格
          for(int i = 1; i <= 2 * crackNum; i++) {
               int index = i + 1;
               model.result().table().create("tbl" + index, "Table");
               model.result().table("tbl" + index).comments("点计算 " + i);
          }
          // 创建应力计算表格
          for(int i = 1; i <= 2 * crackNum; i++) {
          int index = i + 2 * crackNum;
          model.result().table().create("tbl" + index, "Table");
          model.result().table("tbl" + index).comments("应力计算 " + i);
          }

          // 创建全局计算
          model.result().numerical().create("gev1", "EvalGlobal");
          model.result().numerical().create("av1", "AvLine");
          model.result().numerical("av1").selection().set(3);
          model.result().numerical().create("gev2", "EvalGlobal");
          model.result().numerical("gev1").set("data", "dset1");
          model.result().numerical("gev1").set("table", "tbl1");
          model.result().numerical("gev1")
               .set("expr", new String[]{"area1", "area2", "area3", "area4", "area5", "area6", "area7", "area8", "area9", "area10", "area11", "area12", "area13", "area14", "area15", "area16", "area17", "area18", "area19", "area20"});
          model.result().numerical("gev1")
               .set("unit", new String[]{"m^2", "m^2", "m^2", "m^2", "m^2", "m^2", "m^2", "m^2", "m^2", "m^2", "m^2", "m^2", "m^2", "m^2", "m^2", "m^2", "m^2", "m^2", "m^2", "m^2"});
          model.result().numerical("gev1")
               .set("descr", new String[]{"", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""});
          model.result().numerical("gev1")
               .set("const", new String[][]{{"solid.refpntx", "0", "\u529b\u77e9\u8ba1\u7b97\u53c2\u8003\u70b9\uff0cx \u5750\u6807"}, {"solid.refpnty", "0", "\u529b\u77e9\u8ba1\u7b97\u53c2\u8003\u70b9\uff0cy \u5750\u6807"}, {"solid.refpntz", "0", "\u529b\u77e9\u8ba1\u7b97\u53c2\u8003\u70b9\uff0cz \u5750\u6807"}});
          model.result().numerical("av1").set("expr", new String[]{"y"});
          model.result().numerical("av1").set("unit", new String[]{"m"});
          model.result().numerical("av1").set("descr", new String[]{"y \u5750\u6807"});
          model.result().numerical("av1")
               .set("const", new String[][]{{"solid.refpntx", "0", "\u529b\u77e9\u8ba1\u7b97\u53c2\u8003\u70b9\uff0cx \u5750\u6807"}, {"solid.refpnty", "0", "\u529b\u77e9\u8ba1\u7b97\u53c2\u8003\u70b9\uff0cy \u5750\u6807"}, {"solid.refpntz", "0", "\u529b\u77e9\u8ba1\u7b97\u53c2\u8003\u70b9\uff0cz \u5750\u6807"}});
          model.result().numerical("gev2")
               .set("expr", new String[]{"distance1", "distance2", "distance3", "distance4", "distance5", "distance6", "distance7", "distance8", "distance9", "distance10", "distance11", "distance12", "distance13", "distance14", "distance15", "distance16", "distance17", "distance18", "distance19", "distance20"});
          model.result().numerical("gev2")
               .set("unit", new String[]{"m", "m", "m", "m", "m", "m", "m", "m", "m", "m", "m", "m", "m", "m", "m", "m", "m", "m", "m", "m"});
          model.result().numerical("gev2")
               .set("descr", new String[]{"", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""});
          model.result().numerical("gev2")
               .set("const", new String[][]{{"solid.refpntx", "0", "\u529b\u77e9\u8ba1\u7b97\u53c2\u8003\u70b9\uff0cx \u5750\u6807"}, {"solid.refpnty", "0", "\u529b\u77e9\u8ba1\u7b97\u53c2\u8003\u70b9\uff0cy \u5750\u6807"}, {"solid.refpntz", "0", "\u529b\u77e9\u8ba1\u7b97\u53c2\u8003\u70b9\uff0cz \u5750\u6807"}});
                   
          // 创建80个点计算
          for(int i = 1; i <= 2 * crackNum; i++) {
               model.result().numerical().create("pev" + i, "EvalPoint");
               model.result().numerical("pev" + i).set("data", "cpt" + i);
               model.result().numerical("pev" + i).set("table", "tbl" + i);
               model.result().numerical("pev" + i).set("expr", new String[]{"x", "y"});
               model.result().numerical("pev" + i).set("unit", new String[]{"m", "m"});
               model.result().numerical("pev" + i).set("descr", new String[]{"x \u5750\u6807", "y \u5750\u6807"});
               model.result().numerical("pev" + i)
                    .set("const", new String[][]{{"solid.refpntx", "0", "\u529b\u77e9\u8ba1\u7b97\u53c2\u8003\u70b9\uff0cx \u5750\u6807"}, {"solid.refpnty", "0", "\u529b\u77e9\u8ba1\u7b97\u53c2\u8003\u70b9\uff0cy \u5750\u6807"}, {"solid.refpntz", "0", "\u529b\u77e9\u8ba1\u7b97\u53c2\u8003\u70b9\uff0cz \u5750\u6807"}});
               model.result().numerical("pev" + i).setResult();
          }
          for(int i = 1; i <= 2 * crackNum; i++) {
          int index = i + 2 * crackNum;
          model.result().numerical().create("pev" + index, "EvalPoint");
          model.result().numerical("pev" + index).set("data", "cpt" + i);
          model.result().numerical("pev" + index).set("table", "tbl" + index);
          model.result().numerical("pev" + index).set("expr", new String[]{"solid.syy"});
          model.result().numerical("pev" + index).set("unit", new String[]{"Pa"});
          model.result().numerical("pev" + index).set("descr", new String[]{"y方向应力"});
          model.result().numerical("pev" + index).set("const", new String[][]{{"solid.refpntx","0","力矩计算参考点，x 坐标"},{"solid.refpnty","0","力矩计算参考点，y 坐标"},{"solid.refpntz","0","力矩计算参考点，z 坐标"}});
          model.result().numerical("pev" + index).setResult();
          }

          // 创建表格导出，导出的条目有porocity、distance、stressy
          // 合成ARname，例如：16AR1+4AR2
          String ARname = "";
          int count = 0;
          for (CrackData crack : crackManager.getModelConfig().getCrackList()) {
               count++;
               ARname = ARname + crack.getNum() + crack.getName();
               if(count < crackManager.getModelConfig().getCrackList().size()){
                    ARname = ARname + "+";
               }
          }
          // 创建保存目录
          String porocityDir = modelDir + String.format("/%d-cracks-porocity-%d-%d-%s", crackNum, groupNum, n, ARname);
          String distanceDir = modelDir + String.format("/%d-cracks-distance-%d-%d-%s", crackNum, groupNum, n, ARname);
          String stressyDir  = modelDir + String.format("/%d-cracks-stressy-%d-%d-%s", crackNum, groupNum, n, ARname);
          String[] resultDirs = {porocityDir, distanceDir, stressyDir};
          for(String dir : resultDirs) {
               File file = new File(dir);
               if(!file.exists()) {
                    file.mkdirs();
               }
          }

          // 创建导出
          // 导出porocity
          model.result().export().create("tbl" + 1 , "Table");
          model.result().export("tbl" + 1).set("table", "tbl" + 1);
          model.result().export("tbl" + 1).set("filename", porocityDir + String.format("/%d-cracks-porocity-%d-%d-%s.txt", crackNum, groupNum, n, ARname));
          model.result().export("tbl" + 1).run();
          // 导出distance
          for(int i = 1; i <= 2 * crackNum; i++) {
               int index = i + 1;
               model.result().export().create("tbl" + index , "Table");
               model.result().export("tbl" + index).set("table", "tbl" + index);
               model.result().export("tbl" + index).set("filename", distanceDir + String.format("/%d-cracks-distance-%d~40-%d-%s.txt", crackNum, i, n, ARname));
               model.result().export("tbl" + index).run();
          }
          // 导出stressy
          for(int i = 1; i <= 2 * crackNum; i++) {
               int index = i + 2 * crackNum;
               model.result().export().create("tbl" + index , "Table");
               model.result().export("tbl" + index).set("table", "tbl" + index);
               model.result().export("tbl" + index).set("filename", stressyDir + String.format("/%d-cracks-stressy-%d~40-%d-%s.txt", crackNum, i, n, ARname));
               model.result().export("tbl" + index).run();
          }


          // 保存模型
          try {
               model.save(modelDir + String.format("/model_%d-%d.mph", groupNum, n));
           } catch (IOException e) {
               e.printStackTrace(); // 打印异常信息，您可以根据需要进行其他处理
           }

          return model;
     }

     // 为下一轮生成清除结果
     public static void run2(CrackManager crackManager, Model model){
          int crackNum = crackManager.getModelConfig().getCrackList().size();
          model.result().numerical().remove("gev1");
          model.result().numerical().remove("gev2");
          model.result().numerical().remove("av1");
          for(int i = 1; i <= 2 * crackNum; i++){
               model.result().dataset().remove("cpt" + i);
               model.result().numerical().remove("pev" + i);
               model.result().table().remove("tbl" + i);
               model.result().export().remove("tbl" + i);
          }
          
     }

     public static void main(String[] args) {
          Config config = ConfigLoader.load("config.json");
          CrackManager crackManager = new CrackManager(config);
          int subModelNum = crackManager.getModelConfig().getSubModelNum();
          for(int n = 1; n <= subModelNum; n++){
               Model model = run(crackManager, n);
               if (n != subModelNum) {
                    run2(crackManager, model);
               }
          }
     }
}

