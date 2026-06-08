package config;
public class PathConfig {

    private String projectRootDir;

    private String crackPositionDir;

    private String polCrackCoorDir;

    private String resultDir;

    public PathConfig() {}

    public String getProjectRootDir() {
        return projectRootDir;
    }

    public void setProjectRootDir(String projectRootDir) {
        this.projectRootDir = projectRootDir;
    }

    public String getCrackPositionDir() {
        return crackPositionDir;
    }

    public void setCrackPositionDir(String crackPositionDir) {
        this.crackPositionDir = crackPositionDir;
    }

    public String getPolCrackCoorDir() {
        return polCrackCoorDir;
    }

    public void setPolCrackCoorDir(String polCrackCoorDir) {
        this.polCrackCoorDir = polCrackCoorDir;
    }

    public String getResultDir() {
        return resultDir;
    }

    public void setResultDir(String resultDir) {
        this.resultDir = resultDir;
    }
}