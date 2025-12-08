package Main;
import com.comsol.model.*;
import com.comsol.model.util.*;
import java.io.*;

public class EllipseBoundarySelection {
    public static void main(String[] args) {
        // 创建模型
        Model model = ModelUtil.create("Model");
        model.component().create("comp1", false);
        model.component("comp1").geom().create("geom1", 2);

        model.component("comp1").geom("geom1").create("sq1", "Square");
        model.component("comp1").geom("geom1").feature("sq1").set("size", 0.2);

        model.component("comp1").geom("geom1").create("e1", "Ellipse");
        model.component("comp1").geom("geom1").feature("e1").set("semiaxes", new String[]{"0.018", "0.0001"});
        model.component("comp1").geom("geom1").feature("e1").set("pos", new double[]{0.07, 0.07});
        model.component("comp1").geom("geom1").feature("e1").set("selresult", true);
        model.component("comp1").geom("geom1").feature("e1").set("selresultshow", "bnd");
        
        // 运行几何
        model.component("comp1").geom("geom1").run();
        String[] selectionTags = model.component("comp1").selection().tags();
        // int[] ellipseEdges = model.component("comp1").selection("geom1_e1_bnd").entities();



        try (BufferedWriter writer = new BufferedWriter(new FileWriter("E:\\OneDrive\\Project\\Innovation\\src\\log.txt", true))) {
            writer.write("tags:\n");

            StringBuilder sb = new StringBuilder();
            for (String obj : selectionTags) {
                sb.append(obj);
                sb.append("\n");
            }
            
            writer.write(sb.toString());
            writer.write("\n"); // 额外换行以区分不同调用
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
