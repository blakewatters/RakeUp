require 'rake'
require 'rake/tasklib'
require 'rakeup/status'
require 'rakeup/shell'

module RakeUp
  class ServerTask < Rake::TaskLib
    include ::Rake::DSL if defined?(::Rake::DSL)
  
    attr_accessor :name    
    attr_accessor :host
    attr_accessor :port
    attr_accessor :server
    attr_accessor :pid_file
    attr_accessor :rackup_file
    attr_accessor :echo_commands
    attr_accessor :rackup_bin
    
    # Commands
    attr_accessor :run_command
    attr_accessor :start_command
    attr_accessor :stop_command
    attr_accessor :restart_command
  
    def initialize(name = :server)
      @name = name
      @host = 'localhost'
      @port = 4567
      @pid_file = "tmp/#{name}.pid"
      @rackup_file = "#{name}.ru"
      @rackup_bin = "bundle exec rackup"
      @server = "thin"
      @echo_commands = true
      
      yield self if block_given?
      define_tasks
    end
    
    def rackup_command(options = nil)
      [rackup_bin, "-s #{server}", host_option, "-p #{port}", "-P #{pid_file}", options, rackup_file].compact.join(' ')
    end
    
    def host_option
      host && "-o #{host}"
    end
    
    def run_command
      @run_command || rackup_command
    end
    
    def start_command
      @start_command || rackup_command('-D')
    end
    
    def stop_command
      @stop_command || "kill `cat #{pid_file}`"
    end
    
    def restart_command
      @restart_command || "#{stop_command} && #{start_command}"
    end
  
    private
      def define_tasks
        RakeUp::Shell.echo_commands = @echo_commands                
      
        namespace name do
          task :run do
            if File.exists?(pid_file)
              pid = File.read(pid_file).chomp
              server_status = RakeUp::Status.new(pid, host, port)
              server_status.check
              if server_status.up?
                $stderr.puts "Unable to run server: Existing process with pid #{server_status.pid} found listening on #{server_status.host}:#{server_status.port}"
                exit(1)
              end
            end
            
            # Cleanup the pid file on exit
            at_exit { File.delete(pid_file) if File.exists?(pid_file) }
            
            RakeUp::Shell.execute(run_command)
          end

          desc "Start the Test server daemon"
          task :start do
            unless RakeUp::Shell.execute(start_command)
              puts "\033[0;31m!! Failed to start server (exit code: #{$?.exitstatus})"
              exit($?.exitstatus)
            end
          end

          desc "Stop the Test server daemon"
          task :stop do
            unless File.exists?(pid_file)
              puts "\033[0;31m!! Unable to stop server: No pid file found at #{pid_file}"
              exit(-1)
            end
            
            pid = File.read(pid_file).chomp
            server_status = RakeUp::Status.new(pid, host, port)
            server_status.check
            if server_status.listening?
              unless RakeUp::Shell.execute(stop_command)
                puts "\033[0;31m!! Failed stopping server (exit code: #{$?.exitstatus})"
                exit($?.exitstatus)
              end
            else
              File.delete(pid_file)
            end
          end

          desc "Restart the Test server daemon"
          task :restart do
            unless RakeUp::Shell.execute(restart_command)
              puts "\033[0;31m!! Failed restarting server (exit code: #{$?.exitstatus})"
              exit($?.exitstatus)
            end            
          end

          desc "Check the status of the Test server daemon"
          task :status do
            if File.exists?(pid_file)
              pid = File.read(pid_file).chomp
            else
              pid = nil
            end

            server_status = RakeUp::Status.new(pid, host, port)
            server_status.check
            if server_status.listening?
              puts server_status.to_s
            else
              $stderr.puts "!! No server found listening on #{server_status.host_and_port}"
            end
          end
          
          desc "Abort the task chain unless the Test server is running"
          task :abort_unless_running do
            server_status = RakeUp::Status.new(nil, host, port)
            server_status.check
            unless server_status.listening?
              $stderr.puts "!! Aborting: No server found listening on #{server_status.host_and_port}"
              exit(-1)
            end
          end
        
          desc "Starts the server if there is not already an instance running"
          task :autostart do              
            server_status = RakeUp::Status.new(nil, host, port)
            server_status.check
            unless server_status.listening?
              @auto_started = true
              $stderr.puts "!! Auto-starting server: No server found listening on #{server_status.host_and_port}"
              RakeUp::Shell.execute(start_command)
            end
          end
          
          desc "Stops the server if executed via autostart"
          task :autostop do
            server_status = RakeUp::Status.new(nil, host, port)
            server_status.check
            if @auto_started && server_status.listening?
              $stderr.puts "!! Stopping auto-started server listening on #{server_status.host_and_port}"
              RakeUp::Shell.execute(stop_command)
            end
          end
        end

        desc 'Run the Test server in the foreground'
        task name => ["#{name}:run"]        
      end
  end
end
