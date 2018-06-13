require 'cri'

class Criterion
  class CLI
    class Worker
      def self.command
        @cmd ||= Cri::Command.define do
          name        'worker'
          usage       'worker'
          summary     'Runs a criterion worker'

          flag   :h,  :help,  'show help for this command' do |value, cmd|
            puts cmd.help
            exit 0
          end

          option   :u, :uri,            'URI of the RestMQ server', argument: :required
          optional :q,  :queue,         'Queue to subscribe to', default: 'reports'
          optional :h, :mongo_hostname, 'Hostname of the MongoDB server to use', default: 'localhost'
          optional :d, :mongo_database, 'Name of the MongoDB database to use', default: 'criterion'


          run do |opts, args, cmd|
            require 'criterion/worker'
            worker = Criterion::Worker.new(opts)
            worker.run
          end
        end
      end
    end
  end
end

Criterion::CLI.command.add_command(Criterion::CLI::Worker.command)
