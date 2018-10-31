require 'cri'

class Kriterion
  class CLI
    class Worker
      def self.command
        @cmd ||= Cri::Command.define do
          name        'worker'
          usage       'worker --uri <uri>'
          summary     'Runs a kriterion worker'

          flag   :h,  :help,  'show help for this command' do |value, cmd|
            puts cmd.help
            exit 0
          end

          optional :u, :uri,            'URI of the RestMQ server',
                   default: ENV['uri'] || 'http://localhost:8888'
          optional :q, :queue,          'Queue to subscribe to',
                   default: ENV['queue']|| 'reports'
          optional :h, :mongo_hostname, 'Hostname of the MongoDB server to use',
                   default: ENV['mongo_hostname'] || 'localhost'
          optional :d, :mongo_database, 'Name of the MongoDB database to use',
                   default: ENV['mongo_database'] || 'kriterion'
          optional :p, :mongo_port,     'Port for MongoDB',
                   default: ENV['mongo_port'] || 27_017


          run do |opts, _args, _cmd|
            require 'kriterion/worker'
            worker = Kriterion::Worker.new(opts)
            worker.run
          end
        end
      end
    end
  end
end

Kriterion::CLI.command.add_command(Kriterion::CLI::Worker.command)
