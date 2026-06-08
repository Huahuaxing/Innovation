package crack;

import config.Config;
import config.ConfigLoader;

import java.util.List;

public class Test {

    public static void main(String[] args) {

        // ===== 1. 构造 config（你需要确保这里能正常初始化）=====
        Config config = ConfigLoader.load(".\\01_Config\\config.json");

        // ===== 2. 创建 CrackManager =====
        CrackManager manager = new CrackManager(config);

        // ===== 3. 生成裂隙中心坐标 =====
        List<double[]> positions = manager.crackPosition();
        System.out.println("中心坐标生成完成: " + positions.size());

        // ===== 4. 生成边缘坐标 =====
        List<double[][]> coordinates = manager.polCrackCoordinate(positions);
        System.out.println("边缘坐标生成完成: " + coordinates.size());

        // ===== 5. 保存中心坐标 =====
        String posPath = ".\\a";
        manager.saveCrackPosition(positions, posPath);
        System.out.println("中心坐标已保存: " + posPath);

        // ===== 6. 保存边缘坐标 =====
        String coorPath = ".\\b";
        manager.savePolCoordinate(coordinates, coorPath);
        System.out.println("边缘坐标已保存: " + coorPath);

        System.out.println("测试完成");
    }
}