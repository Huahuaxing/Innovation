package config;

import java.util.List;

import crack.CrackData;

public class ModelConfig {

    private double squareSize;
    private int groupNum;
    private int subModelNum;
    private String crackShape;
    private int crackNum;
    private String crackSource;
    private List<CrackData> crackList;  // 将 crackList 移到这里

    public double getSquareSize() { return squareSize; }
    public void setSquareSize(double squareSize) { this.squareSize = squareSize; }

    public int getGroupNum() { return groupNum; }
    public void setGroupNum(int groupNum) { this.groupNum = groupNum; }

    public int getSubModelNum() { return subModelNum; }
    public void setSubModelNum(int subModelNum) { this.subModelNum = subModelNum; }

    public String getCrackShape() { return crackShape; }
    public void setCrackShape(String crackShape) { this.crackShape = crackShape; }

    public int getCrackNum() { return crackNum; }
    public void setCrackNum(int crackNum) { this.crackNum = crackNum; }

    public String getCrackSource() { return crackSource; }
    public void setCrackSource(String crackSource) { this.crackSource = crackSource; }

    public List<CrackData> getCrackList() { return crackList; }
    public void setCrackList(List<CrackData> crackList) { this.crackList = crackList; }
}