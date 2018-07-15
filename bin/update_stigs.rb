require 'nokogiri'
require 'json'
require 'open-uri'
require 'pry'

main_page = Nokogiri::HTML(open("https://www.stigviewer.com/stigs"))

main_page.search('td').each do |td|
  begin
    standard      = {}
    standard_link = td.children[1].attributes['href'].value
    puts "Searching #{standard_link} for JSON"
    standard_page = Nokogiri::HTML(open("https://www.stigviewer.com#{standard_link}"))
    json_link     = standard_page.at_css('[id="json"]').attributes['href'].value
    puts "Downloading JSON: #{json_link}"
    stig          = JSON.parse(open("https://www.stigviewer.com#{json_link}").read)['stig']

    # Map elements
    standard['name'] = "stig_#{stig['slug']}"
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

puts 'done'
