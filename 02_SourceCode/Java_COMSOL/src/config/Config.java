package config;
import java.util.List;

import crack.CrackData;

public class Config {

    private ModelConfig modelConfig;

    private List<CrackData> crackList;

    private PathConfig pathConfig;

    public Config() {}

    public ModelConfig getModelConfig() {
        return modelConfig;
    }

    public void setModelConfig(ModelConfig model) {
        this.modelConfig = model;
    }

    public List<CrackData> getCrackList() {
        return crackList;
    }

    public void setCrackList(List<CrackData> cracks) {
        this.crackList = cracks;
    }

    public PathConfig getPathConfig() {
        return pathConfig;
    }

    public void setPathConfig(PathConfig path) {
        this.pathConfig = path;
    }
}