module FCZ
  #require 'lib/contants.rb'
  #require 'lib/logger.rb'
  #Dir[File.dirname(__FILE__) + '/lib/*.rb'].each { |file| require file }

  ['contants',
   'logger',
   'fetcher_fast',
   'fetcher_slow',
   'PageShot',
   'pos',
   'reporter_csv',
   'reporter_xls',
   'sysconfig'].each do |f|
    require "lib/#{f}.rb"
  end
end