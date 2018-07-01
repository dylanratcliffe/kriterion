require 'net/http'
require 'uri'
require 'pry'

uri     = ARGV[0]
queue   = 'reports'
uri     = URI("#{uri}/q/#{queue}")
threads = []
files   = Dir["spec/reports/*.json"]

files.each do |file|
  threads << Thread.new do
    http    = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.request_uri)
    request.body = URI.escape("value=#{File.read(file)}").gsub(';','%3B')
    http.request(request)
  end
end

threads.map(&:join)
