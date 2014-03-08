module FCZ
  class CsvReporter
    #require 'win32ole'

    def initialize(dateRange) #格式:12.20-12.25
      @logger = FCZLogger.instance
      filename="“飞常准”民意测评(#{dateRange}).csv"

      #必要时创建目录
      Dir.mkdir DIR_OUT unless File.exist? DIR_OUT

      #必要时创建文件
      @record_file="#{DIR_OUT}/#{filename}"
      if !Dir.exist? @record_file
        @logger.info "目标文件不存在，正在从模板中创建..."
        require "fileutils"
        FileUtils.cp_r(TPL_CSV, @record_file)
        @logger.info "成功创建#{@record_file}"
      end
    end

    def save(item)
      item.keys.each do |key|
         if item[key].class == String
           item[key].gsub(',','；')
         end
      end
      @logger.info "保存信息..."
      File.open(@record_file, 'a') do |hFile|
        #A    B     C      D         E         F      G              H
        #日期 航段  航班号 星级评分  旅客评价  乘务组 乘务长所在分部 程序备注
        hFile.puts "#{item[:airdate]},#{item[:airline]},#{item[:aircode]},#{item[:nstars]},#{item[:detail]}, , ,#{item[:remark]};#{item[:strStars]}"
      end
    end
  end
end