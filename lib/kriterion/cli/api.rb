require 'cri'

class Kriterion
  class CLI
    class API
      def self.command
        @cmd ||= Cri::Command.define do
          name        'api'
          usage       'api --standards_dir <uri>'
          summary     'Runs a kriterion API server'

          flag   :h,  :help,  'show help for this command' do |value, cmd|
            puts cmd.help
            exit 0
          end

          option   :u, :standards_dir,            'URI of the RestMQ server', argument: :required
          optional :h, :mongo_hostname, 'Hostname of the MongoDB server to use', default: 'localhost'
          optional :d, :mongo_database, 'Name of the MongoDB database to use', default: 'kriterion'
          optional :p, :mongo_port,     'Port for MongoDB', default: 27017


          run do |opts, args, cmd|
            # TODO: Get log levels working properly
            require 'kriterion/api'
            worker = Kriterion::API.new(opts)
            worker.run
          end
        end
      end
    end
  end
end

Kriterion::CLI.command.add_command(Kriterion::CLI::API.command)
