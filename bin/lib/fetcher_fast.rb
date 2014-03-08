#encoding utf-8
module FCZ
	require 'nokogiri'
	require 'open-uri'
	class QuickFetcher

		StarChar="★"
		MAX_TRY=5
		def initialize(timeline,aircode="ZH")
		  @logger = FCZLogger.instance
		  @aircode=aircode
		  @timeline = timeline

      @pageshot=PageShot.new
		end

		# @return stopped? result
		def fetcher(nPage)
			url="#{URL_FCZ}#{nPage}"
			@logger.info "正在抓取第#{nPage}页"
			
			arrResult=[]
			bBreak=false
			
			try_countor=0
			begin
				try_countor += 1
				doc = Nokogiri::HTML(open(url))
        page_shot = @pageshot.save_to doc.to_html,"page=#{nPage}"
				doc.css("div.pllist").each do |div|
					strTitle = div.css("/table/tr/td/p").first.text
					strStar = div.css("div.star").css("/table/tr/td/p").last.text
					strDetail = div.css("p").last.text
					puts strTitle
					
					reg=/.*?(?<pbdate>\d{4}-\d{1,2}-\d{1,2}).*?(?<pbtime>\d{1,2}:\d{1,2}:\d{1,2}).*?(?<airdate>\d{4}-\d{1,2}-\d{1,2})(?<airline>.*?-.*?)\s+.*?(?<aircode>[A-Z0-9]+?)\s.*/
					result = reg.match(strTitle)
					if result.nil? or result.length != 6
						@logger.error("匹配错误！，请手动确认:#{url}")
					end
					
					datetime="#{result[:pbdate]} #{result[:pbtime]} +0800"
					pbdatetime=DateTime.parse(datetime).to_time
				
					if pbdatetime <= @timeline
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
					content[:remark]="截图:#{page_shot}"
				
					content.each_pair do |k,v|
						@logger.debug "Hash: #{k}=>#{v}"
					end
					
					arrResult.push(content) if content[:aircode].include? @aircode if @aircode
				end
			rescue
				@logger.warn "发现异常：$!.message"
				if try_countor < MAX_TRY
					retry
				else
					raise $!
				end
			end
			return bBreak,arrResult
		end
		
		def close()
			@logger.info "关闭抓取器"
		end
		
		def countStars(str)
		  return str if str == "暂无评价"
		  count = 0
		  str.each_char do|s|
			if(s == StarChar)
			count +=1
			end
		  end
		  return count
		end
	end
end