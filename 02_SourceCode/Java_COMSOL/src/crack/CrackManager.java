package crack;
import java.util.ArrayList;
import java.util.List;
import java.util.Scanner;

import config.Config;
import config.ModelConfig;
import config.PathConfig;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.nio.file.Path;

   
public class CrackManager {

    private final ModelConfig modelConfig;
    private final PathConfig pathConfig;

    public CrackManager(Config config) {
        this.modelConfig = config.getModelConfig();
        this.pathConfig = config.getPathConfig();
        
    }

    // 获取模型配置
    public ModelConfig getModelConfig() {
        return this.modelConfig;
    }

    // 获取路径配置
    public PathConfig getPathConfig() {
        return this.pathConfig;
    }

    // 获取裂隙数据列表
    public List<CrackData> getCrackList() {
        return this.modelConfig.getCrackList();
    }

    // 获取裂隙总数
    public int getCracksNum(){
        int num = 0;
        for (CrackData crack : this.modelConfig.getCrackList()) {
            num += crack.getNum();
        }
        return num;
    }

    // 获取所有裂隙的b0，c0数组，(crackNum, 2)
    public List<double[]> getARList() {
        List<double[]> arList = new ArrayList<>();
        
        for(CrackData crack : this.modelConfig.getCrackList()) {
            for(int i = 1; i <= crack.getNum(); i++) {
                arList.add(new double[]{crack.getB0(), crack.getC0()});
            }
        }
        return arList;
    }

    // 生成一个子模型的裂隙中心坐标，(crackNum, 2)
    public List<double[]> crackPosition() {
        List<double[]> positionList = new ArrayList<>();
        List<double[]> arList = getARList();

        for (int i = 0; i < arList.size(); i++) {
            boolean placed = false;
            double crackAperture = 2 * arList.get(i)[0];
            double crackLength = 2 * arList.get(i)[1];

            while (!placed) {
                double x = Math.random() * (modelConfig.getSquareSize() - (0.02 + crackLength)) + 0.01 + crackLength / 2;
                double y = Math.random() * (modelConfig.getSquareSize() - (0.02 + crackAperture)) + 0.01 + crackAperture / 2;

                x = Math.floor(x * 1000) / 1000;
                y = Math.floor(y * 1000) / 1000;

                boolean overlap = false;

                for (int j = 0; j < positionList.size(); j++) {
                    double dx = Math.abs(positionList.get(j)[0] - x);
                    double dy = Math.abs(positionList.get(j)[1] - y);

                    double xLength = arList.get(j)[1] + arList.get(i)[1] + 0.01;
                    double yLength = arList.get(j)[0] + arList.get(i)[0] + 0.01;

                    if (dx <= xLength && dy <= yLength) {
                        overlap = true;
                        break;
                    }
                }

                if (!overlap) {
                    positionList.add(new double[]{x, y});
                    placed = true;
                }
            }
        }
        return positionList;
    }


    // 生成非椭圆裂隙（多边形裂隙）边缘坐标
    public List<double[][]> polCrackCoordinate(List<double[]> positionList) {
        List<double[][]> coordinateList = new ArrayList<>();
        List<double[]> arList = getARList();

        for (int i = 0; i < positionList.size(); i++) {
            double[][] coordinates = new double[40][2];
            double b0 = arList.get(i)[0];
            double c0 = arList.get(i)[1];

            for (int j = 0; j <= 20; j++) {
                double standardX = -c0 + j * (2 * c0 / 20);
                double ux = b0 * Math.pow(1 - Math.pow(standardX / c0, 2), 1.5);

                double x = Math.round((standardX + positionList.get(i)[0]) * 1000000.0) / 1000000.0;
                double y1 = Math.round((ux + positionList.get(i)[1]) * 1000000.0) / 1000000.0;
                double y2 = Math.round((-ux + positionList.get(i)[1]) * 1000000.0) / 1000000.0;

                if (j == 0 || j == 20) {
                    coordinates[j] = new double[]{x, y1};
                } else {
                    coordinates[j] = new double[]{x, y1};
                    coordinates[40 - j] = new double[]{x, y2};
                }
            }

            coordinateList.add(coordinates);
        }

        return coordinateList;
    }

    
    // 读取单个子模型裂隙中心坐标
    public List<double[]> readCrackPosition(int modelIndex) {
        List<double[]> positionList = new ArrayList<>();

        Path path = Path.of(
            this.pathConfig.getReadPositionDir(),
            "position" + modelIndex + ".txt"
        );

        try (Scanner sc = new Scanner(path)) {
            while (sc.hasNextLine()) {
                String[] arr = sc.nextLine().split(",");
                positionList.add(new double[]{
                    Double.parseDouble(arr[0].trim()),
                    Double.parseDouble(arr[1].trim())
                });
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return positionList;
    }


    // 读取单个子模型非椭圆裂隙边缘坐标
    public List<double[][]> readPolCoordinate(int modelIndex) {
        List<double[][]> coordinateList = new ArrayList<>();

        for (int j = 1; j <= this.modelConfig.getCrackNum(); j++) {

            List<double[]> crack = new ArrayList<>();

            Path path = Path.of(
                this.pathConfig.getReadCoorDir(),
                "data_coordinates_" + modelIndex,
                "coordinates" + j + ".txt"
            );

            try (Scanner sc = new Scanner(path)) {
                while (sc.hasNextLine()) {
                    String[] arr = sc.nextLine().split(",");
                    crack.add(new double[]{
                        Double.parseDouble(arr[0].trim()),
                        Double.parseDouble(arr[1].trim())
                    });
                }
            } catch (Exception e) {
                e.printStackTrace();
            }

            coordinateList.add(crack.toArray(new double[0][0]));
        }

        return coordinateList;
    }


    // 保存裂隙中心坐标（单子模型）
    public void saveCrackPosition(List<double[]> positionList, int modelIndex) {

        Path filePath = Path.of(
            this.pathConfig.getSavePositionDir(),
            "position" + modelIndex + ".txt"
        );

        File file = filePath.toFile();
        File parent = file.getParentFile();

        if (parent != null && !parent.exists()) {
            parent.mkdirs();
        }

        try (FileWriter fw = new FileWriter(file)) {

            for (double[] p : positionList) {
                fw.write(p[0] + ", " + p[1] + "\n");
            }

        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    // 保存非椭圆裂隙边缘坐标（单子模型）
    public void savePolCoordinate(List<double[][]> coordinateList, int modelIndex) {

        Path folderPath = Path.of(
            this.pathConfig.getSaveCoorDir(),
            "data_coordinates_" + modelIndex
        );

        File folder = folderPath.toFile();

        if (!folder.exists()) {
            folder.mkdirs();
        }

        for (int i = 0; i < coordinateList.size(); i++) {

            Path filePath = folderPath.resolve("coordinates" + (i + 1) + ".txt");

            try (FileWriter fw = new FileWriter(filePath.toFile())) {

                for (double[] point : coordinateList.get(i)) {
                    fw.write(point[0] + ", " + point[1] + "\n");
                }

            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }

}
