package config;
public class ModelConfig {

    private double squareSize;
    private int groupNum;
    private int subModelNum;
    private String crackShape;
    private int crackNum;

    public ModelConfig() {}

    public double getSquareSize() {
        return squareSize;
    }

    public void setSquareSize(double squareSize) {
        this.squareSize = squareSize;
    }

    public int getGroupNum() {
        return groupNum;
    }

    public void setGroupNum(int groupNum) {
        this.groupNum = groupNum;
    }

    public int getSubModelNum() {
        return subModelNum;
    }

    public void setSubModelNum(int subModelNum) {
        this.subModelNum = subModelNum;
    }

    public String getCrackShape() {
        return crackShape;
    }

    public void setCrackShape(String crackShape) {
        this.crackShape = crackShape;
    }

    public int getCrackNum() {
        return crackNum;
    }

    public void setCrackNum(int crackNum) {
        this.crackNum = crackNum;
    }
}