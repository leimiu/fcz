module FCZ
  require 'watir-webdriver'
  require 'date'

  class BrowserFetcher
    StarChar="★"

    def initialize(timeline,air_code='ZH')
      @logger = FCZLogger.instance
      @timeline = timeline
      @air_code = air_code

      @browser = Watir::Browser.new :firefox
      # @browser.speed=:zippy
      @logger.info "Browser initialized."
      @ssaver = PageShot.new
    end

    # @return stopped? result
    def fetcher(nPage)
      @logger.info "正在抽取第#{nPage}页的数据..."
      url="#{URL_FCZ}#{nPage}"
      @browser.goto url
      screen_shot=@ssaver.save_to @browser,"page=#{nPage}"

      arrResult=[]
      bBreak=false
      10.times do |i|
        div=@browser.div(:class => "pllist", :index => i)
        if div.exist?
          begin
            strTitle=div.table.tr.td(:index => 1).p.text
            strStar=div.div(:class => "star").td(:index => 2).p(:index => 1).text
            strDetail=div.td(:index => 1).p(:index => 7).text

            reg=/.*(?<pbdate>\d{4}-\d{1,2}-\d{1,2}).*?\s+(?<pbtime>\d{1,2}:\d{1,2}:\d{1,2}).*(?<airdate>\d{4}-\d{1,2}-\d{1,2})\s+(?<airline>.*?-.*?)\s+(?<aircode>\w+?)\s+.*/
            result = reg.match(strTitle)
            if result.nil? or result.length != 6
              @logger.error("匹配错误！，请手动确认:#{url}")
              @logger.info "保存出错截图"
              @ssaver.save_screen "page=#{nPage}_index=#{i}_regError"

              htmlfile="errorshot_regErr_#{now.strftime("%Y%m%d_%H%M%S")}"
              @logger.info "保存出错html快照到#{htmlfile}"
              savehtml htmlfile
              next
            end

            if strDetail.nil? or strDetail.length ==0
              @logger.warn("评价内容为空！请手动确认:#{url}")
            end

            datetime="#{result[:pbdate]} #{result[:pbtime]} +0800"
            pbdatetime=DateTime.parse(datetime).to_time
            if pbdatetime < @timeline
              @logger.debug "获取到评价发布时间:#{pbdatetime}，而抽取截止时间：#{@timeline}"
              @logger.info("已经找到上次已经抽取的位置：#{result[:pbdate]} #{result[:pbtime]}。如有疑问，请手动确认：#{url}")
              bBreak =true
              break
            end

            content={}
            content[:pbdate] = result[:pbdate].strip
            content[:pbtime] = result[:pbtime].strip
            content[:airdate] = result[:airdate].strip
            content[:airline] = result[:airline].strip
            content[:aircode] = result[:aircode].strip
            content[:strStars]=strStar.strip
            content[:nstars]=countStars(strStar)
            content[:detail]=strDetail
            content[:remark]="截图:#{screen_shot}"

            #将信息打印出来调试
            content.each_pair do |k, v|
              @logger.debug "Hash: #{k}=>#{v}"
            end

            #过滤掉非深圳航空的信息
            arrResult.push(content) if content[:aircode].include? @air_code  if @aircode
          rescue
            @logger.error "Error:#{$!} at: #{$@}"
            @logger.error "无法定位评价信息。地址：#{url}，位置：#{i}"

            @logger.info "保存出错截图"
            @ssaver.save_screen "page=#{nPage}_index=#{i}_cmtError"

            htmlfile="errorshot_cmtErr_#{now.strftime("%Y%m%d_%H%M%S")}"
            @logger.info "保存出错html快照到#{htmlfile}"
            savehtml htmlfile
            raise $!

          ensure

          end
        else
          @logger.warn("Index=#{i}时的div不存在！")
        end

      end

      return bBreak, arrResult
    end

    def countStars(str)
      return str if str == "暂无评价"
      count = 0
      str.each_char do |s|
        if (s == StarChar)
          count +=1
        end
      end
      return count
    end

    def close()
      @logger.info "关闭浏览器"
      @browser.close if @browser
    end

    def savehtml(to)
      f=File.new("#{::WORK_DIR}/shots/#{to}.html")
      f.puts @browser.html
      f.close
    end

  end
end