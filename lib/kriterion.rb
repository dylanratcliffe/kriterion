require 'json'

class Kriterion
  ROOT = File.dirname __dir__

  def self.standards(paths)
    standards = {}
    paths.each do |path|
      Dir["#{path}/*.json"].each do |file|
        standard = JSON.parse(File.read(file))
        standards[standard['name']] = standard
      end
    end
    standards
  end
end
