package config;
import java.io.File;

import com.fasterxml.jackson.databind.ObjectMapper;

public class ConfigLoader {

    private ConfigLoader() {}

    public static Config load(String configPath) {

        try {

            ObjectMapper mapper = new ObjectMapper();

            return mapper.readValue(new File(configPath), Config.class);

        } catch (Exception e) {

            throw new RuntimeException("读取配置文件失败: " + configPath, e);
        }
    }
}