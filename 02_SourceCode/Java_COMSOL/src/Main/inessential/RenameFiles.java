package Main.inessential;

import java.io.File;
import java.util.Arrays;

public class RenameFiles {
    public static void main(String[] args) {
        // 指定目录
        File dir = new File("./Data");
        
        // 获取目录下所有文件
        File[] files = dir.listFiles();
        
        if (files != null) {
            System.out.println("排序前：");
            for (File file : files) {
                System.out.println(file.getName());
            }
            
            // 修改排序逻辑
            Arrays.sort(files, (f1, f2) -> {
                int num1 = Integer.parseInt(f1.getName().replace(".txt", ""));
                int num2 = Integer.parseInt(f2.getName().replace(".txt", ""));
                return num1 - num2;
            });
            
            System.out.println("\n排序后：");
            for (File file : files) {
                System.out.println(file.getName());
            }
            
            // 重命名文件
            for (int i = 0; i < files.length; i++) {
                String newName = (i + 1) + "-40.txt";
                File newFile = new File(dir, newName);
                files[i].renameTo(newFile);
            }
        }
    }
}