module FCZ
  class FCZLogger
    require'Logger'
    require 'lib/contants'
    ::LogLevel=Logger::DEBUG

    def initialize
      if(!File.exist?(DIR_LOG))
        Dir.mkdir(DIR_LOG) #if folder not exist,then creat it.
      end
      
      @stdLogger = Logger.new(STDOUT) #输出到控制台
      @stdLogger.level = ::LogLevel
      
      date=Time.new.strftime("%Y%m%d")
      @fileLogger = Logger.new("#{DIR_LOG}/fcz_#{date}.log")
      @fileLogger.level = ::LogLevel
      
    end
    
    @@inst = FCZLogger.new
    def self.instance
      return @@inst
    end
    
   
    def error(msg)
      @stdLogger.error(msg)
      @fileLogger.error(msg)
    end
    
    def info(msg)
      @stdLogger.info(msg)
      @fileLogger.info(msg)
    end
    
    def warn(msg)
      @stdLogger.warn(msg)
      @fileLogger.warn(msg)
    end
   
   def debug(msg)
     @stdLogger.debug(msg)
     @fileLogger.debug(msg)
   end
   
  end
  
end