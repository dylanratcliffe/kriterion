require 'nokogiri'
require 'json'
require 'open-uri'
require 'pry'

def process_td(td)
  begin
    standard      = {}
    standard_link = td.children[1].attributes['href'].value
    puts "Searching #{standard_link} for JSON"
    standard_page = Nokogiri::HTML(open("https://www.stigviewer.com#{standard_link}"))
    json_link     = standard_page.at_css('[id="json"]').attributes['href'].value
    puts "Downloading JSON: #{json_link}"
    stig          = JSON.parse(open("https://www.stigviewer.com#{json_link}").read)['stig']

    # Map elements
    standard['name'] = "stig_#{stig['slug']}".tr(':', '_')
    standard['date'] = stig['date']
    standard['description'] = stig['description']
    standard['title'] = stig['title']
    standard['version'] = stig['version']
    standard['item_syntax'] = '^\w-\d+$'
    standard['section_separator'] = nil
    standard['items'] = stig['findings'].map { |id,details|
      {
        'id'          => id,
        'title'       => details['title'],
        'description' => details['description'],
        'severity'    => details['severity'],
      }
    }

    puts "Writing standard #{standard['name']}"
    File.write("standards/#{standard['name']}.json", JSON.pretty_generate(standard))
  rescue
    puts 'Something went wrong, pretending it didn\'t happen'
  end
end

main_page   = Nokogiri::HTML(open("https://www.stigviewer.com/stigs"))
@queue      = Queue.new
NUM_THREADS = 30

main_page.search('td').each do |td|
  @queue.push(td)
end

@threads = Array.new(NUM_THREADS) do
  Thread.new do
    until @queue.empty?
      # This will remove the first object from @queue
      next_object = @queue.shift

      process_td(next_object)
    end
  end
end

@threads.each(&:join)

puts 'done'
