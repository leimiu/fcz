require 'pathname'
Dir.chdir "../"
::WORK_DIR=Dir.pwd
$LOAD_PATH.unshift(::WORK_DIR)
require 'lib/logger'
require 'lib/sysconfig'

puts FCZ::FCZConfig.speed
