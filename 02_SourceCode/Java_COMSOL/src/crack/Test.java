package crack;

import config.Config;
import config.ConfigLoader;

import java.util.List;

public class Test {

    public static void main(String[] args) {

        Config config = ConfigLoader.load(".\\01_Config\\config.json");
        CrackManager manager = new CrackManager(config);

        int subModelNum = config.getModelConfig().getSubModelNum();

        // // =====================================================
        // // ① 生成中心坐标
        // // =====================================================
        // System.out.println("===== ① 生成中心坐标 =====");
        // for (int i = 1; i <= subModelNum; i++) {

        //     List<double[]> positions = manager.crackPosition();

        //     System.out.println("模型 " + i + " 中心数量: " + positions.size());
        // }

        // // =====================================================
        // // ② 保存中心坐标（使用 savePositionDir）
        // // =====================================================
        // System.out.println("===== ② 保存中心坐标 =====");
        // for (int i = 1; i <= subModelNum; i++) {

        //     List<double[]> positions = manager.crackPosition();

        //     manager.saveCrackPosition(positions, i);

        //     System.out.println("模型 " + i + " 保存完成");
        // }

        // =====================================================
        // ③ 读取中心坐标 + 验证保存
        // =====================================================
        System.out.println("===== ③ 读取中心坐标 + 验证保存 =====");
        for (int i = 1; i <= subModelNum; i++) {

            List<double[]> positions = manager.readCrackPosition(i);

            manager.saveCrackPosition(
                positions,
                i  // 再保存到同结构（验证）
            );

            System.out.println("模型 " + i + " 读取+验证保存完成");
        }

        // // =====================================================
        // // ④ 生成边缘坐标
        // // =====================================================
        // System.out.println("===== ④ 生成边缘坐标 =====");
        // for (int i = 1; i <= subModelNum; i++) {

        //     List<double[]> positions = manager.crackPosition();
        //     List<double[][]> coordinates = manager.polCrackCoordinate(positions);

        //     System.out.println("模型 " + i + " 边缘数量: " + coordinates.size());
        // }

        // // =====================================================
        // // ⑤ 保存边缘坐标（使用 saveCoorDir）
        // // =====================================================
        // System.out.println("===== ⑤ 保存边缘坐标 =====");
        // for (int i = 1; i <= subModelNum; i++) {

        //     List<double[]> positions = manager.crackPosition();
        //     List<double[][]> coordinates = manager.polCrackCoordinate(positions);

        //     manager.savePolCoordinate(coordinates, i);

        //     System.out.println("模型 " + i + " 保存完成");
        // }

        // =====================================================
        // ⑥ 读取边缘坐标 + 验证保存
        // =====================================================
        System.out.println("===== ⑥ 读取边缘坐标 + 验证保存 =====");
        for (int i = 1; i <= subModelNum; i++) {

            List<double[][]> coordinates = manager.readPolCoordinate(i);

            manager.savePolCoordinate(coordinates, i);

            System.out.println("模型 " + i + " 读取+验证保存完成");
        }

        System.out.println("===== 全部测试完成 =====");
    }
}