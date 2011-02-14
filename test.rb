
Dir[File.join(File.dirname(__FILE__), 'lib', '*.rb')].each do |file|
  require file
end

include RQTRotate

File.open(ARGV[0], File::RDWR) do |datastream|
  degrees = get_rotation(datastream)
  
  puts "rotation is #{degrees}"

  if degrees != 0
    datastream.rewind

    puts "rotating from #{degrees}"
    rotate(datastream, 270)
  end
end
