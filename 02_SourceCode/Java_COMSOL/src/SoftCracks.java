// import java.util.List;

// 要生成不同组模型，只需要修改m和addCrackData中的参数

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;

import com.comsol.model.*;
import com.comsol.model.util.*;


public class SoftCracks {

     static int num_cycles = 5;

     public static Model run(int n){

          int group = 6;

          // 裂隙类型，椭圆或多边形
          String crackType = "ellipse";

          Crack crack = new Crack(2);

          crack.addCrackData("AR1", 0.0001, 0.018, 16);
          crack.addCrackData("AR2", 0.00005, 0.018, 4);

          double ARList[][] = crack.getARList();

          int cracksNum = crack.getCracksNum();

          Model model = ModelUtil.create("Model");

          // model.modelPath("E:\\OneDrive\\Project\\Innovation");

          // 创建全局变量
          if(crackType.equals("ellipse")){
               for(int i = 1; i <= ARList.length; i++){
                    model.param().set("b" + i, ARList[i-1][0] + " [m]");
                    model.param().set("c" + i, ARList[i-1][1] + " [m]");
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
                  

          // 创建裂隙，作差集，用一个if-else语句创建椭圆或多边形裂隙
          double[][] positions = new double[cracksNum][2];
          if(crackType.equals("ellipse")){
               // 从文件中读取裂隙坐标，使椭圆裂隙坐标和多边形裂隙相同
               positions = new double[cracksNum][2];
               try (BufferedReader reader = new BufferedReader(new FileReader("E:\\OneDrive\\Project\\Innovation\\Data\\" + group + "\\position" + n + ".txt"))) {
                    String line;
                    for(int i = 0; i < cracksNum; i++){
                         line = reader.readLine();
                         String[] coordinates = line.split(",");
                         positions[i][0] = Double.parseDouble(coordinates[0].trim());
                         positions[i][1] = Double.parseDouble(coordinates[1].trim());
                    }
               } catch (NumberFormatException | IOException e) {
                    System.err.println("Error reading position file for group " + group + ", n=" + n + ": " + e.getMessage());
                    e.printStackTrace();
               }
               for(int i = 1; i <= cracksNum; i++){
                    model.component("comp1").geom("geom1").create("e" + i, "Ellipse");
                    model.component("comp1").geom("geom1").feature("e" + i).set("pos", positions[i-1]);
                    model.component("comp1").geom("geom1").feature("e" + i).set("rot", 90);
                    model.component("comp1").geom("geom1").feature("e" + i).set("semiaxes", new String[]{"b" + i, "c" + i});
                    model.component("comp1").geom("geom1").feature("e" + i).set("selresult", true);
                    model.component("comp1").geom("geom1").feature("e" + i).set("selresultshow", "bnd");  

                    if(i == 1){
                         model.component("comp1").geom("geom1").create("dif" + i, "Difference");
                         model.component("comp1").geom("geom1").feature("dif" + i).selection("input").set("sq1");
                         model.component("comp1").geom("geom1").feature("dif" + i).selection("input2").set("e" + i);
                    }else{
                         model.component("comp1").geom("geom1").create("dif" + i, "Difference");
                         model.component("comp1").geom("geom1").feature("dif" + i).selection("input").set("dif" + (i - 1));
                         model.component("comp1").geom("geom1").feature("dif" + i).selection("input2").set("e" + i);
                    }
               }
          }else if(crackType.equals("polygon")){
               positions = crack.cracks_position(n);

               crack.cracks_coordinates(positions, n);

               for(int i = 1; i <= cracksNum; i++){
                    model.component("comp1").geom("geom1").create("pol" + i, "Polygon");
                    model.component("comp1").geom("geom1").feature("pol" + i).set("source", "file");
                    model.component("comp1").geom("geom1").feature("pol" + i).set("filename", "E:\\OneDrive\\Project\\Innovation\\Data\\Coordinates\\data_coordinates_" + n + "\\coordinates" + i + ".txt");
                    model.component("comp1").geom("geom1").feature("pol" + i).set("selresult", true);
                    model.component("comp1").geom("geom1").feature("pol" + i).set("selresultshow", "bnd");    
                    if(i == 1){
                         model.component("comp1").geom("geom1").create("dif" + i, "Difference");
                         model.component("comp1").geom("geom1").feature("dif" + i).selection("input").set("sq1");
                         model.component("comp1").geom("geom1").feature("dif" + i).selection("input2").set("pol" + i);
                    }else{
                         model.component("comp1").geom("geom1").create("dif" + i, "Difference");
                         model.component("comp1").geom("geom1").feature("dif" + i).selection("input").set("dif" + (i - 1));
                         model.component("comp1").geom("geom1").feature("dif" + i).selection("input2").set("pol" + i);
                    }
               }
          }
          
          model.component("comp1").geom("geom1").run();
          
          // 创建变量var1，var2
          model.component("comp1").variable().create("var1");
          model.component("comp1").variable().create("var2");
          for(int i = 1; i <= crack.getCracksNum(); i++){
               model.component("comp1").variable("var1").set(String.format("area%d", i), String.format("intop%d(-x*solid.nx)", i));
               model.component("comp1").variable("var2").set(String.format("distance%d", i), String.format("aveop%d(y)-aveop%d(y)", 2*i-1, 2*i));
          }

          // 获取裂隙边界序号,奇数取裂隙上面，偶数取下面
          int edgeNum = 0;
          if(crackType.equals("ellipse")){
               edgeNum = 4;
          }else if(crackType.equals("polygon")){
               edgeNum = 40;
          }
          int[][] polEdges = new int[cracksNum][edgeNum];
          if(crackType.equals("ellipse")){
               for(int i = 1; i <= cracksNum; i++){
                    polEdges[i-1] = model.component("comp1").selection("geom1_e" + i + "_bnd").entities();
               }
          }else if(crackType.equals("polygon")){
               for(int i = 1; i <= cracksNum; i++){
                    polEdges[i-1] = model.component("comp1").selection("geom1_pol" + i + "_bnd").entities();
               }
          }

          // 创建积分，平均值，接触对
          if(crackType.equals("ellipse")){
               for(int i = 1; i <= cracksNum; i++){
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
          }else if(crackType.equals("polygon")){
               for(int i = 1; i <= cracksNum; i++){
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
          if(crackType.equals("ellipse")) {
               model.component("comp1").physics("solid").feature("roll1").selection().set(2, 4);
          } else {
               model.component("comp1").physics("solid").feature("roll1").selection().set(2, 804);
          }
          model.component("comp1").physics("solid").prop("AdvancedSettings").set("GroupPhysOdesRd", false);
          model.component("comp1").physics("solid").feature("lemm1").set("IsotropicOption", "CpCs");
          model.component("comp1").physics("solid").feature("lemm1").set("cp_mat", "userdef");
          model.component("comp1").physics("solid").feature("lemm1").set("cp", 2118.9);
          model.component("comp1").physics("solid").feature("lemm1").set("cs_mat", "userdef");
          model.component("comp1").physics("solid").feature("lemm1").set("cs", 1254.7);
          model.component("comp1").physics("solid").feature("lemm1").set("rho_mat", "userdef");
          model.component("comp1").physics("solid").feature("lemm1").set("rho", "2.02e3");
          model.component("comp1").physics("solid").feature("bndl1").set("LoadType", "FollowerPressure");
          model.component("comp1").physics("solid").feature("bndl1").set("FollowerPressure", "p_in");
          model.component("comp1").physics("solid").feature("bndl1")
               .set("weight", "(sqrt((solid.bndl1.x2^2)+(solid.bndl1.x3^2)))<=solid.bndl1.lc");
     
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
          // model.result().create("pg1", "PlotGroup2D");
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
          
          // 2D points
          double leftX = 0;
          double rightX = 0;
          double interval = 0;    // spacing
          double pointy = 0;      // y coordinate
          for (int i = 1; i <= 40; i++) {
               leftX = positions[(i - 1) / 2][0] - ARList[(i - 1) / 2][1];
               rightX = positions[(i - 1) / 2][0] + ARList[(i - 1) / 2][1];
               interval = (rightX - leftX)/20;
               pointy = positions[(i - 1) / 2][1];
               
               model.result().dataset().create("cpt" + i, "CutPoint2D");
               model.result().dataset("cpt" + i).set("pointx", "range("+leftX+","+interval+","+rightX+")");
               if(i % 2 != 0) {
                    pointy = pointy + 0.0001;
               }else {
                    pointy = pointy - 0.0001;
               }
               model.result().dataset("cpt" + i).set("pointy", pointy);
               model.result().dataset("cpt" + i).set("snapping", "boundary");
               model.result().dataset("cpt" + i).set("pointvar", "cpt"+ i + "n");
          }

          // globle compute
          model.result().numerical().create("gev1", "EvalGlobal");
          model.result().numerical().create("av1", "AvLine");
          model.result().numerical("av1").selection().set(3);
          model.result().numerical().create("gev2", "EvalGlobal");
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
          
          // table and comments
          for(int i = 1; i <= 40; i++) {
               model.result().table().create("tbl" + i, "Table");
               model.result().table("tbl" + i).comments("\u70b9\\u8ba1\\u7b97 " + i);
               }

          // point compute
          for(int i = 1; i <= 40; i++) {
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

          // create ExportTable
          String ARname = "";
          int count = 0;
          for (Crack.CrackData data : crack.getCrackDataList()) {
               count++;
               ARname = ARname + data.getNum() + data.getName();
               if(count < crack.getCrackDataList().size()){
                    ARname = ARname + "+";
               }
          }
          

          String filePath1 = "E:/OneDrive/Project/Innovation/Data/Finally";
          String filePath2 = filePath1 + String.format("/%d-cracks-distance-%d-%d-%s", cracksNum, group, n, ARname);
          File file = new File(filePath2);
          if(!file.exists()){
               file.mkdirs();
          }

          for(int i = 1; i <= 40; i++) {
               model.result().export().create("tbl" + i , "Table");
               model.result().export("tbl" + i).set("table", "tbl" + i);
               model.result().export("tbl" + i)
                         .set("filename", filePath2 + String.format("/%d-cracks-distance-%d~40-%d-%s.txt", cracksNum, i, n, ARname)); // 20-cracks-1_5-0.0001_0.018/data_1-40.txt
               model.result().export("tbl" + i).run();
          }


          // 保存模型
          String newModeldir = "";
          if (crackType.equals("ellipse")) {
               newModeldir = String.format("D:/Projects/Innovation/Data/source/ellipse_aligned_source/第%d组_%s", group, ARname);
          } else {
               newModeldir = String.format("D:/Projects/Innovation/Data/source/polygonal_source/第%d组_%s", group, ARname);
          }
          File newModelDir = new File(newModeldir);
          if(!newModelDir.exists()){
               newModelDir.mkdirs();
          }

          try {
               String newModelPath = String.format(newModeldir + "/%d-%d.mph", group, n); // 新的文件路径
               model.save(newModelPath);
           } catch (IOException e) {
               e.printStackTrace(); // 打印异常信息，您可以根据需要进行其他处理
           }

          return model;
     }

     // 为下一轮生成清除结果
     public static void run3(Model model){

          model.result().numerical().remove("gev1");
          model.result().numerical().remove("gev2");
          model.result().numerical().remove("av1");
          for(int i = 1; i <= 40; i++){
               model.result().dataset().remove("cpt" + i);
               model.result().numerical().remove("pev" + i);
               model.result().table().remove("tbl" + i);
               model.result().export().remove("tbl" + i);
          }
          
     }

     public static void main(String[] args) {
          
          for(int n = 1; n <= num_cycles; n++){

               Model model = run(n);

               if (n != num_cycles) {
                    run3(model);
               }
          }
     }
}

