
Dir[File.join(File.dirname(__FILE__), 'lib', '*.rb')].each do |file|
  require file
end

include RQTRotate

Movie.new(:file_name => ARGV[0]) do |movie|
  degrees = movie.rotation  
  puts "rotation is #{degrees}"

  movie.rotation = degrees + 90
end
