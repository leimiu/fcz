module FCZ
  class XlsReporter
    require 'win32ole'
    TplXlsx='tpl/fcz_tpl.xlsx'
    OutDir='out'

    def initialize(dateRange)
      #raise "TEST/"
      @logger = FCZLogger.instance
      file_name="“飞常准”民意测评(#{dateRange}).xlsx"

      #必要时创建目录
      Dir.mkdir OutDir unless File.exist? OutDir

      #必要时创建文件
      xlsFile="#{OutDir}/#{file_name}"
      if !Dir.exist? xlsFile
        @logger.info "目录文件不存在，正在从模板中创建"
        require "fileutils"
        FileUtils.cp_r(TPL_XLS, xlsFile)
        @logger.info "成功创建#{xlsFile}"
      end

      file="#{::WORK_DIR}/#{xlsFile}"
      @logger.debug "Target file: #{file}"

      WIN32OLE.codepage = WIN32OLE::CP_UTF8
      @excel = WIN32OLE::new('excel.Application')
      @excel.visible = true

      @workbook = @excel.Workbooks.Open(file)
      @worksheet =@workbook.Worksheets(1) #定位到第一个sheet
      @worksheet.Select

      #写表头
      @worksheet.Range('a1').Value ="“飞常准”民航网旅客评价\n#{dateRange}"
    end

    def save(item)
      #找到第一处a列的值为空值
      line = 3 #line的值为第一处空白行的行数，从第三行开始找
      while @worksheet.Range("a#{line}").Value
        line+=1
      end
      #A    B     C      D         E         F      G              H
      #日期 航段  航班号 星级评分  旅客评价  乘务组 乘务长所在分部 程序备注
      @worksheet.Range("A#{line}").Value = item[:airdate]
      @worksheet.Range("B#{line}").Value = item[:airline]
      @worksheet.Range("C#{line}").Value = item[:aircode]
      @worksheet.Range("D#{line}").Value = item[:nstars]
      @worksheet.Range("E#{line}").Value = item[:detail]
      @worksheet.Range("H#{line}").Value = item[:remark]
    end

    def close()
      begin
        @workbook.Close(1) if @workbook #确保最后关闭excel
        @excel.Quit if @excel
      rescue
        @logger.warn "关闭excel时异常：#{$!.message}"
      end
    end

  end
end