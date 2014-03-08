module FCZ
  require 'lib/contants.rb'
  require 'lib/logger.rb'
  Dir[File.dirname(__FILE__) + '/lib/*.rb'].each { |file| require file }
end