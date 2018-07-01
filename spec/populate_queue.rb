require 'net/http'
require 'uri'
require 'pry'

uri     = ARGV[0]
queue   = 'reports'
uri     = URI("#{uri}/q/#{queue}")
HTTP    = Net::HTTP.new(uri.host, uri.port)
REQUEST = Net::HTTP::Post.new(uri.request_uri)
threads = []
files   = Dir["spec/reports/*.json"]

files.each do |file|
  threads << Thread.new do
    REQUEST.body = URI.escape("value=#{File.read(file)}").gsub(';','%3B')
    HTTP.request(REQUEST)
  end
end

threads.map(&:join)
