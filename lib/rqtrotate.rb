
Dir[File.join(File.dirname(__FILE__), 'rqtrotate', '*.rb')].each do |file|
  require file
end

module RQTRotate
end
