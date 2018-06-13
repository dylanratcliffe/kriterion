require 'cri'

class Criterion
  class CLI
    @cmd ||= Cri::Command.define do
      name        'criterion'
      usage       'criterion <subcommand>'
      summary     'Exposes Puppet\'s compliance information in a REST API'

      flag   :h,  :help,  'show help for this command' do |value, cmd|
        puts cmd.help
        exit 0
      end

      flag :d, :debug, 'Enable debug logging'

      run do |opts, args, cmd|
        puts cmd.help
        exit 0
      end
    end
  end
end
