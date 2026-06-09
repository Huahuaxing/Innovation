package config;

public class PathConfig {

    private String projectRootDir;
    private String readPositionDir;
    private String readCoorDir;
    private String savePositionDir;
    private String saveCoorDir;
    private String resultDir;

    public PathConfig() {}

    public String getProjectRootDir() {
        return projectRootDir;
    }

    public void setProjectRootDir(String projectRootDir) {
        this.projectRootDir = projectRootDir;
    }

    public String getReadPositionDir() {
        return readPositionDir;
    }

    public void setReadPositionDir(String readPositionDir) {
        this.readPositionDir = readPositionDir;
    }

    public String getReadCoorDir() {
        return readCoorDir;
    }

    public void setReadCoorDir(String readCoorDir) {
        this.readCoorDir = readCoorDir;
    }

    public String getSavePositionDir() {
        return savePositionDir;
    }

    public void setSavePositionDir(String savePositionDir) {
        this.savePositionDir = savePositionDir;
    }

    public String getSaveCoorDir() {
        return saveCoorDir;
    }

    public void setSaveCoorDir(String saveCoorDir) {
        this.saveCoorDir = saveCoorDir;
    }

    public String getResultDir() {
        return resultDir;
    }

    public void setResultDir(String resultDir) {
        this.resultDir = resultDir;
    }
}