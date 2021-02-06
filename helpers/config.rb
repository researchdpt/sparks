module Helpers
    class << self
        attr_accessor :config
    end

    class Config
        def initialize
            config_file = File.read("config.yaml")
            @@config = YAML.load(config_file)
            puts "#{Time.now.strftime("[%Y/%m/%d %H:%M:%S.%L]")} \e[33m!!\e[0m [config loader] Config loaded."
        end    

        def config
            @@config
        end

        def get(path)
            unless @@config.dig(*path.split(":")).nil? 
                @@config.dig(*path.split(":")) 
            else
                false
            end
        end
    end

    config_obj = Config.new
    self.config = config_obj
end
