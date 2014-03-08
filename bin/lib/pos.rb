module FCZ
  class FetcherPos
    def initialize(air_code)
      @pos_path="#{DIR_CFG}/lastpos@#{air_code}.txt"
      @logger = FCZLogger.instance
    end

    def loadpos()
      #加载上次的位置
      @logger.info "尝试从位置文件#{@pos_path}中获取上次最后抓取的位置..."
      line=nil;
      File.open(@pos_path) { |f| line = f.gets.strip } rescue true
      last_time = DateTime.parse(line).to_time if line

      if last_time.nil?
        @logger.info "未能获取上次的位置，从3d前开始抓取"
        d = DateTime.now
        d -= 3
        last_time = DateTime.parse("#{d.strftime('%Y-%m-%d')} 00:00:00 +0800").to_time
      end
      @logger.debug "抓取截止时间为：#{last_time}"
      return last_time
    end

    def savepos(date_str)
      File.open(@pos_path, 'wb') { |f| f.puts date_str }
    end

  end
end