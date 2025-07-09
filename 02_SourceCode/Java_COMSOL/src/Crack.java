import java.util.ArrayList;
import java.util.List;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.Arrays; // 确保导入 Arrays 类


public class Crack {

    double squareSize = 0.2;
    public int typeNum; // 支持的裂隙类型数量
    private List<CrackData> crackDataList; // 存储每种裂隙类型的数据

    // 构造函数
    public Crack(int typeNum) {
        this.typeNum = typeNum;
        this.crackDataList = new ArrayList<>();
    }

    // 内部类：存储单个裂隙类型的数据
    public static class CrackData {
        private String name;    
        private double b0;
        private double c0;
        private int num;

        public CrackData(String name, double b0, double c0, int num) {
            this.name = name;
            this.b0 = b0;
            this.c0 = c0;
            this.num = num;
        }

        // Getter 方法
        public String getName() {
            return name;
        }

        public double getB0() {
            return b0;
        }

        public double getC0() {
            return c0;
        }

        public int getNum() {
            return num;
        }
    }

    // 添加裂隙数据，b0是裂隙开度，c0是裂隙长度
    public void addCrackData(String name, double b0, double c0, int num) {
        if (crackDataList.size() < typeNum) {
            crackDataList.add(new CrackData(name, b0, c0, num));
        } else {
            throw new IllegalStateException("已达到裂隙类型数量上限: " + typeNum);
        }
    }

    // 获取裂隙数据列表
    public List<CrackData> getCrackDataList() {
        return crackDataList;
    }

    // 获取裂隙总数
    public int getCracksNum(){
        int num = 0;
        for (CrackData crack : crackDataList) {
            num += crack.num;
        }
        return num;
    }

    // 获取b0，c0二维数组
    public double[][] getARList() {
        int index = 0;      // index 为裂隙总数
        double[][] ARList = new double[this.getCracksNum()][2];
        for (CrackData crack : crackDataList) {
            for(int i = 0; i < crack.getNum(); i++) {
                ARList[index][0] = crack.getB0(); // 存储 b0
                ARList[index][1] = crack.getC0(); // 存储 c0
                index++; // 增加索引
            }
        }

        return ARList;
    }

    public double[][] cracks_position(int n) {
        // Create a folder to store crack coordinates
        String filePath1 = "E:/OneDrive/Project/Innovation/Data/Position";
        File file1 = new File(filePath1);
        if (!file1.exists()) {
            file1.mkdirs();
        }

        int cracksNum = this.getCracksNum();
        double[][] ARList = this.getARList();
        
        // Create a 2D array to store crack positions
        double[][] cracks_positions = new double[cracksNum][2];
        
        // Generate crack positions 
        for(int i = 0; i < cracksNum; i++) {
            boolean placed = false;

            double crackApperture = 2 * ARList[i][0];
            double crackLength    = 2 * ARList[i][1];

            while(!placed){

                double[] position = new double[2];

                // 设定裂隙位置区间
                position[0] = Math.random() * (this.squareSize - (0.02 + crackLength)) + 0.01 + crackLength/2;          // 裂隙距离岩石边缘至少有0.01的距离，确保收敛
                position[1] = Math.random() * (this.squareSize - (0.02 + crackApperture)) + 0.01 + crackApperture/2;    // y坐标设置到0.01-0.19区间内，否则容易不收敛

                // 保留三位小数
                position[0] = Math.floor(position[0] * 1000) / 1000;
                position[1] = Math.floor(position[1] * 1000) / 1000;

                if(position[0] <= crackLength/2 || position[0] >= (this.squareSize - crackLength/2) || position[1] <= crackApperture/2 || position[1] >= (this.squareSize - crackApperture/2)){
                    continue;
                }
                
                // Check if the crack position overlaps with previous crack positions
                boolean overlap = false;
                for(int j = 0; j < i; j++){
                    double dx = Math.abs(cracks_positions[j][0] - position[0]);
                    double dy = Math.abs(cracks_positions[j][1] - position[1]);

                    double yLength = ARList[j][0] + ARList[i][0] + 0.01;
                    double xLength = ARList[j][1] + ARList[i][1] + 0.01;

                    // 为了更好收敛，裂隙之间的上下间距需要大于0.001
                    if(dx <= xLength && dy <= yLength){
                        overlap = true;
                        break;
                    }
                }
                // If the crack position does not overlap, store it in the array
                if(!overlap){
                    cracks_positions[i][0] = position[0];
                    cracks_positions[i][1] = position[1];
                    placed = true;
                }
            }

        }

        // Store the crack positions in a file
        String filePath2 = "E:/OneDrive/Project/Innovation/Data/Position/position" + n + ".txt";
        File file2 = new File(filePath2);
        if (!file2.exists()) {
            try {
                file2.createNewFile();
            } catch (IOException e) {
                e.printStackTrace(); // 处理异常
            }
        }   
        try {
            FileWriter fw = new FileWriter(file2);
            for(int i = 0; i < cracksNum; i++){
                fw.write(cracks_positions[i][0] + ", " + cracks_positions[i][1] + "\n");
            }
            fw.close(); 
        } catch (IOException e) {
            e.printStackTrace(); // 处理异常
        }

        return cracks_positions;
    }

    public List<double[][]> cracks_coordinates(double[][] cracks_positions, int n) {
        // Create a folder to store crack coordinates
        String filePath1 = "E:/OneDrive/Project/Innovation/Data/Coordinates/data_coordinates_" + n;
        File file1 = new File(filePath1);
        if (!file1.exists()) {
            file1.mkdirs();
        }

        // Generate crack  points coordinates
        List<double[][]> cracks_coordinates = new ArrayList<>(); // numPosition, 40, 2

        for (int i = 0; i < cracks_positions.length; i++) {
            // 一个多边形裂隙用40个点绘制
            double[][] coordinates = new double[40][2];

            double[][] ARList = this.getARList();
            double b0 = ARList[i][0];
            double c0 = ARList[i][1];

            for (int j = 0; j <= 20; j++) {
                double standardX = (-c0 + j * (2 * c0 / 20));
                double Ux = b0 * Math.pow(1 - Math.pow(standardX / c0, 2), 1.5);

                double xValue = Math.floor((standardX + cracks_positions[i][0]) * 1000000.0) / 1000000.0;
                double yValue1 = Math.floor((Ux + cracks_positions[i][1]) * 1000000.0) / 1000000.0;
                double yValue2 = Math.floor((-Ux + cracks_positions[i][1]) * 1000000.0) / 1000000.0;

                // [0]和[20]是裂隙左右两个顶点，独有的，在这之后[1]对应[39]，[2]对应[38]，以此类推
                if(j == 0 || j == 20){
                    coordinates[j] = new double[]{xValue, yValue1};
                }
                else{
                    coordinates[j] = new double[]{xValue, yValue1};
                    coordinates[40-j] = new double[]{xValue, yValue2};
                }
            }

            // Write to file
            String filePath2 = filePath1 + "/coordinates" + (i + 1) + ".txt";
            File file2 = new File(filePath2);
            if (!file2.exists()) {
                try {
                    file2.createNewFile();
                } catch (IOException e) {
                    e.printStackTrace(); // 处理异常
                }
            }

            try (FileWriter fw = new FileWriter(file2)) {
                for (double[] coordinate : coordinates) {
                    fw.write(coordinate[0] + ", " + coordinate[1] + "\n");
                }
            } catch (IOException e) {
                e.printStackTrace();
            }

            cracks_coordinates.add(coordinates);
        }
        return cracks_coordinates;
    }
    
    public static void main(String[] args) {
        // 创建一个支持 2 种裂隙类型的 Crack 实例
        Crack crack = new Crack(2);

        // 添加裂隙数据
        crack.addCrackData("AR3", 0.009, 0.018, 16);
        crack.addCrackData("AR2", 0.00005, 0.018, 4);

        // 获取并打印裂隙数据
        for (Crack.CrackData data : crack.getCrackDataList()) {
            System.out.println("Name: " + data.getName() + 
                             ", b0: " + data.getB0() + 
                             ", c0: " + data.getC0() + 
                             ", num: " + data.getNum());
        }

        System.out.println(Arrays.deepToString(crack.getARList())); // 打印二维数组的内容
        double[][] cracks_positions = crack.cracks_position(1);
        crack.cracks_coordinates(cracks_positions, 1);
    }
}
