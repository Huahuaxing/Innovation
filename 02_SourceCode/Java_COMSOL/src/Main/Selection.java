package Main;
/*
 * Untitled.java
 */

import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;

import com.comsol.model.*;
import com.comsol.model.util.*;

/** Model exported on Mar 30 2025, 21:04 by COMSOL 6.2.0.290. */
public class Selection {

  public static Model run() {
    Model model = ModelUtil.create("Model");

    model.modelPath("E:\\OneDrive\\Project\\Innovation\\src");

    model.param().set("b0", "0.0001[m]");
    model.param().set("c0", "0.018[m]");

    model.component().create("comp1", false);

    model.component("comp1").geom().create("geom1", 2);
    model.component("comp1").geom("geom1").create("sq1", "Square");
    model.component("comp1").geom("geom1").feature("sq1").set("size", 0.2);
    model.component("comp1").geom("geom1").create("e1", "Ellipse");
    model.component("comp1").geom("geom1").feature("e1").set("selresult", true);
    model.component("comp1").geom("geom1").feature("e1").set("selresultshow", "bnd");
    model.component("comp1").geom("geom1").feature("e1").set("pos", new double[]{0.07, 0.07});
    model.component("comp1").geom("geom1").feature("e1").set("semiaxes", new String[]{"c0", "b0"});
    model.component("comp1").geom("geom1").create("e2", "Ellipse");
    model.component("comp1").geom("geom1").feature("e2").set("selresult", true);
    model.component("comp1").geom("geom1").feature("e2").set("selresultshow", "bnd");
    model.component("comp1").geom("geom1").feature("e2").set("pos", new double[]{0.08, 0.08});
    model.component("comp1").geom("geom1").feature("e2").set("semiaxes", new String[]{"c0", "b0"});
    model.component("comp1").geom("geom1").create("e3", "Ellipse");
    model.component("comp1").geom("geom1").feature("e3").set("selresult", true);
    model.component("comp1").geom("geom1").feature("e3").set("selresultshow", "bnd");
    model.component("comp1").geom("geom1").feature("e3").set("pos", new double[]{0.09, 0.09});
    model.component("comp1").geom("geom1").feature("e3").set("semiaxes", new String[]{"c0", "b0"});
    model.component("comp1").geom("geom1").create("e4", "Ellipse");
    model.component("comp1").geom("geom1").feature("e4").set("selresult", true);
    model.component("comp1").geom("geom1").feature("e4").set("selresultshow", "bnd");
    model.component("comp1").geom("geom1").feature("e4").set("pos", new double[]{0.1, 0.1});
    model.component("comp1").geom("geom1").feature("e4").set("semiaxes", new String[]{"c0", "b0"});
    model.component("comp1").geom("geom1").create("pol1", "Polygon");
    model.component("comp1").geom("geom1").feature("pol1").set("source", "table");
    model.component("comp1").geom("geom1").feature("pol1")
          .set("table", new String[][]{{"0.03200", "0.09000"}, 
          {"0.03380", "0.09002"}, 
          {"0.03560", "0.09004"}, 
          {"0.03740", "0.09007"}, 
          {"0.03920", "0.09010"}, 
          {"0.04100", "0.09013"}, 
          {"0.04280", "0.09015"}, 
          {"0.04460", "0.09017"}, 
          {"0.04640", "0.09019"}, 
          {"0.04820", "0.09020"}, 
          {"0.05000", "0.09020"}, 
          {"0.05180", "0.09020"}, 
          {"0.05360", "0.09019"}, 
          {"0.05540", "0.09017"}, 
          {"0.05720", "0.09015"}, 
          {"0.05900", "0.09013"}, 
          {"0.06080", "0.09010"}, 
          {"0.06260", "0.09007"}, 
          {"0.06440", "0.09004"}, 
          {"0.06620", "0.09002"}, 
          {"0.06800", "0.09000"}, 
          {"0.03200", "0.09000"}, 
          {"0.03380", "0.08998"}, 
          {"0.03560", "0.08996"}, 
          {"0.03740", "0.08993"}, 
          {"0.03920", "0.08990"}, 
          {"0.04100", "0.08987"}, 
          {"0.04280", "0.08985"}, 
          {"0.04460", "0.08983"}, 
          {"0.04640", "0.08981"}, 
          {"0.04820", "0.08980"}, 
          {"0.05000", "0.08980"}, 
          {"0.05180", "0.08980"}, 
          {"0.05360", "0.08981"}, 
          {"0.05540", "0.08983"}, 
          {"0.05720", "0.08985"}, 
          {"0.05900", "0.08987"}, 
          {"0.06080", "0.08990"}, 
          {"0.06260", "0.08993"}, 
          {"0.06440", "0.08996"}, 
          {"0.06620", "0.08998"}, 
          {"0.06800", "0.09000"}});
    model.component("comp1").geom("geom1").feature("pol1").set("selresult", true);
    model.component("comp1").geom("geom1").feature("pol1").set("selresultshow", "bnd");
    model.component("comp1").geom("geom1").create("pol2", "Polygon");
    model.component("comp1").geom("geom1").feature("pol2").set("source", "table");
    model.component("comp1").geom("geom1").feature("pol2")
          .set("table", new String[][]{{"0.00200", "0.02000"}, 
          {"0.00380", "0.02002"}, 
          {"0.00560", "0.02004"}, 
          {"0.00740", "0.02007"}, 
          {"0.00920", "0.02010"}, 
          {"0.01100", "0.02013"}, 
          {"0.01280", "0.02015"}, 
          {"0.01460", "0.02017"}, 
          {"0.01640", "0.02019"}, 
          {"0.01820", "0.02020"}, 
          {"0.02000", "0.02020"}, 
          {"0.02180", "0.02020"}, 
          {"0.02360", "0.02019"}, 
          {"0.02540", "0.02017"}, 
          {"0.02720", "0.02015"}, 
          {"0.02900", "0.02013"}, 
          {"0.03080", "0.02010"}, 
          {"0.03260", "0.02007"}, 
          {"0.03440", "0.02004"}, 
          {"0.03620", "0.02002"}, 
          {"0.03800", "0.02000"}, 
          {"0.00200", "0.02000"}, 
          {"0.00380", "0.01998"}, 
          {"0.00560", "0.01996"}, 
          {"0.00740", "0.01993"}, 
          {"0.00920", "0.01990"}, 
          {"0.01100", "0.01987"}, 
          {"0.01280", "0.01985"}, 
          {"0.01460", "0.01983"}, 
          {"0.01640", "0.01981"}, 
          {"0.01820", "0.01980"}, 
          {"0.02000", "0.01980"}, 
          {"0.02180", "0.01980"}, 
          {"0.02360", "0.01981"}, 
          {"0.02540", "0.01983"}, 
          {"0.02720", "0.01985"}, 
          {"0.02900", "0.01987"}, 
          {"0.03080", "0.01990"}, 
          {"0.03260", "0.01993"}, 
          {"0.03440", "0.01996"}, 
          {"0.03620", "0.01998"}, 
          {"0.03800", "0.02000"}});
    model.component("comp1").geom("geom1").feature("pol2").set("selresult", true);
    model.component("comp1").geom("geom1").feature("pol2").set("selresultshow", "bnd");
    
    model.component("comp1").geom("geom1").run();
    model.component("comp1").geom("geom1").run("fin");

    // int[] e1Edges = model.component("comp1").selection("geom1_e1_bnd").entities();
    int[] pol1Edges = model.component("comp1").selection("geom1_pol1_bnd").entities();
    int[] pol2Edges = model.component("comp1").selection("geom1_pol2_bnd").entities();


    try (BufferedWriter writer = new BufferedWriter(new FileWriter("E:\\OneDrive\\Project\\Innovation\\src\\log.txt", true))) {
      writer.write("pol1Edges:\n");
      for (int obj : pol1Edges) {
          writer.write(obj + " ");
          writer.write("\n");
      }

      writer.write("pol2Edges:\n");
      for (int obj : pol2Edges) {
          writer.write(obj + " ");
          writer.write("\n");
      }

  } catch (IOException e) {
      e.printStackTrace();
  }

    model.component("comp1").view("view1").axis().set("xmin", -0.06814470887184143);
    model.component("comp1").view("view1").axis().set("xmax", 0.3798113465309143);
    model.component("comp1").view("view1").axis().set("ymin", -0.03943390026688576);
    model.component("comp1").view("view1").axis().set("ymax", 0.2355661243200302);

    return model;
  }

  public static void main(String[] args) {
    run();
  }

}
