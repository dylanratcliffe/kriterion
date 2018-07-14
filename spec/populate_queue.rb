require 'net/http'
require 'uri'
require 'pry'

uri        = ARGV[0]
queue      = 'reports'
uri        = URI("#{uri}/q/#{queue}")
threads    = []
files      = Dir["spec/reports/*.json"]
file_queue = Queue.new

files.each { |f| file_queue << f }

puts "Found files:\n#{files.join("\n")}"

4.times do
  threads << Thread.new do
    until queue.empty?
      file    = file_queue.pop(true) rescue nil
      if file
        http    = Net::HTTP.new(uri.host, uri.port)
        request = Net::HTTP::Post.new(uri.request_uri)
        puts "Uploading #{file}"
        request.body = URI.escape("value=#{File.read(file)}").gsub(';','%3B')
        http.request(request)
        puts "Completed upload #{file}"
      end
    end
  end
end

threads.map(&:join)

puts "Done"
