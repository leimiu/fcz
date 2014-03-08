module FCZ
  require 'pathname'
  ::WORK_DIR=Pathname.new(File.dirname(__FILE__)).realpath
  $LOAD_PATH.unshift(::WORK_DIR)
  Encoding.default_external = "UTF-8"

  require 'rubygems'
  require 'requires.rb'
  require 'date'
  logger = FCZLogger.instance
  fetcher_pos = FetcherPos.new FCZConfig.air_code
  timeline = fetcher_pos.loadpos()

  #开始解释配置文件
  speed=FCZConfig.speed
  fetcher=(speed and speed == 'slow') ? BrowserFetcher.new(timeline, FCZConfig.air_code) : QuickFetcher.new(timeline, FCZConfig.air_code)
  logger.info "Speed Mode: #{speed}"

  start_page = FCZConfig.start_page
  start_page = 0 if start_page.nil? or start_page.class.to_s != 'Fixnum'
  logger.info "Start Page: #{start_page}"
  #结束解释配置文件

  bBreak = false
  lastDateline=nil
  saver = nil
  repeat_arr=[]
  while !bBreak
    logger.info "抽取第#{(start_page)}页..."
    bBreak, list = fetcher.fetcher start_page
    logger.info "获取到#{list.size}条记录。"

    #仅在第一次获取位置时保存下来，因为web上的信息是反序的。
    lastDateline = "#{list[0][:pbdate]} #{list[0][:pbtime]} +0800" if lastDateline.nil? and list.size>0

    #仅在获取了最新的记录并且未创建saver时创建记录器
    if lastDateline and saver.nil?
      start_date =DateTime.parse(timeline.to_s).strftime('%Y.%m.%d').to_s
      end_date = DateTime.parse(lastDateline.to_s).strftime('%Y.%m.%d').to_s
      range = "#{start_date}-#{end_date}"
      begin
        logger.info "正在尝试打开xls文件"
        saver = XlsReporter.new "#{FCZConfig.air_code}@#{range}"
      rescue
        logger.warn "创建xls失败：#{$!.message}"
        logger.info "正尝试常见csv格式..."
        saver.close if saver
        saver = CsvReporter.new "#{FCZConfig.air_code}@#{range}"
        logger.info "CSV创建成功"
      end
      raise "创建记录器失败！" unless saver
    end

    #逐条记录内容
    list.each do |item|
      item[:remark]+=";评论内容重复,请手动确认." if item[:detail].size> 3 and repeat_arr.include? item[:detail]
      saver.save item
      repeat_arr<<item[:detail]
    end
    start_page += 1
  end
  fetcher.close
  saver.close if saver.public_methods.include? :close

  #保存位置信息
  fetcher_pos.savepos(lastDateline) if lastDateline
end