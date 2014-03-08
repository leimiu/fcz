module FCZ
  module FCZConfig
    @logger = FCZLogger.instance
    require 'yaml'
    @config = YAML::load(File.open(SYS_CONFIG))
    @logger.debug "Loaded Config: #{@config}"

    @config.each_pair do |k, v|
      define_method(k.to_s) do
        return v
      end
    end

    def set_config(k, v)
      @logger.debug "Setting config: #{k} => #{v}"
      @config[k]=v
    end

    def save()
      File.open(SYS_CONFIG, 'w') { |f| YAML.dump(@config, f) }
    end

    module_function *(@config.keys)
    module_function :set_config, :save
  end
end