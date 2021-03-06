require 'cri'

class Kriterion
  class CLI
    class API
      def self.command
        @cmd ||= Cri::Command.define do
          name        'api'
          usage       'api --standards_dir <uri>'
          summary     'Runs a kriterion API server'

          flag   :h,  :help,  'show help for this command' do |_value, cmd|
            puts cmd.help
            exit 0
          end

          optional :u, :uri,            'URI of the RestMQ server',
                   default: ENV['uri'] || 'http://localhost:8888'
          optional :q, :queue,          'Queue to subscribe to',
                   default: ENV['queue'] || 'reports'
          optional :h, :mongo_hostname, 'Hostname of the MongoDB server to use',
                   default: ENV['mongo_hostname'] || 'localhost'
          optional :d, :mongo_database, 'Name of the MongoDB database to use',
                   default: ENV['mongo_database'] || 'kriterion'
          optional :p, :mongo_port,     'Port for MongoDB',
                   default: ENV['mongo_port'] || 27_017

          run do |opts, _args, _cmd|
            # TODO: Get log levels working properly
            require 'kriterion/api'

            # Create a new worker withe the options we want, run! will detect
            # this
            Kriterion::API.new(opts)
            Kriterion::API.run!
          end
        end
      end
    end
  end
end

Kriterion::CLI.command.add_command(Kriterion::CLI::API.command)
