require 'cri'

class Kriterion
  class CLI
    def self.command
      @cmd ||= Cri::Command.define do
        name        'kriterion'
        usage       'kriterion <subcommand>'
        summary     'Exposes Puppet\'s compliance information in a REST API'

        flag   :h,  :help,  'show help for this command' do |value, cmd|
          puts cmd.help
          exit 0
        end

        flag :d,  :debug, 'Enable debug logging'
        flag nil, :trace, 'Print stacktraces'

        run do |opts, args, cmd|
          puts cmd.help
          exit 0
        end
      end
    end
  end
end

require 'kriterion/cli/worker'
