require 'json'

class Kriterion
  def self.standards(paths)
    standards = {}
    paths.each do |path|
      Dir["#{path}/*.json"].each do |file|
        binding.pry
        standards[file] = JSON.parse(file)
      end
    end
  end
end
