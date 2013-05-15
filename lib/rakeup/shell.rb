module RakeUp
  module Shell    
    class << self
      # When true, commands will be echoed before execution
      def echo_commands=(on_off)
        @echo_commands = on_off
      end
      
      def echo_commands?
        @echo_commands
      end
      
      def execute(command)
        puts "Executing: `#{command}`" if echo_commands?
        system(command)
      end
    end
  end
end
