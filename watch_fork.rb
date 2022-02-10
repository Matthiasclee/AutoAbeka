fork do
  opts = ""
  opts = opts + " " + ARGV[3] if ARGV[3]
  opts = opts + " " + ARGV[4] if ARGV[4]
  `ruby watch.rb #{ARGV[0]} #{ARGV[1]} #{ARGV[2]}#{opts} > /dev/null`
  puts "Done"
end
