module FCZ
  class PageShot
    def initialize()
      @logger = FCZLogger.instance
    end
    def save_to(content,name)
      return "NO_SHOT" unless FCZConfig.page_shot

      Dir.mkdir(DIR_SHOT) unless File.exist?(DIR_SHOT)

      datetime=Time.new.strftime("%Y%m%d_%H%M%S")
      filename="fcz_#{datetime}_#{name}"

      puts content.class
      case content
        when Watir::Browser
          savepath="#{DIR_SHOT}/#{filename}.png"
          content.driver.save_screenshot savepath
        when String
          savepath="#{DIR_SHOT}/#{filename}.html"
          File.open(savepath,'w'){|f| f.puts content}
        else
          raise "未知类型：#{content.class.to_s}"
      end
      @logger.info "快照保存在：#{savepath}"

      return savepath
    end
  end
end