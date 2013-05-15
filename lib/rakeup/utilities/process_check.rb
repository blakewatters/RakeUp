module RakeUp
  module Utilities
    class ProcessCheck
      attr_reader :pid, :error

      def initialize(pid)
        @pid = pid.to_i
      end

      def run
        begin
          info = Process.getpgid(pid)
          @running = true
        rescue Errno::ESRCH => error
          @running = false
          @error = error
        end
      end

      def running?
        @running
      end

      def to_s
        if running?
          "Found process running with pid #{pid}"
        else
          "Unable to find process with pid #{pid}: #{@error}"
        end
      end
    end
  end
end
