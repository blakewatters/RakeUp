require 'socket'
require 'timeout'

module RakeUp
  module Utilities
    class PortCheck
      attr_reader :host, :port, :error

      def initialize(host, port)
        @host = host
        @port = port
      end

      def open?
        @status == true
      end

      def closed?
        @status == false
      end

      def run
        @status = run_check
      end

      def to_s
        if open?
          "Found process listening on #{host}:#{port}"
        else
          "Unable to connect to process on #{host}:#{port}: #{error}"
        end
      end

      private
        def run_check
          begin
            Timeout::timeout(1) do
              begin
                s = TCPSocket.new(host, port)
                s.close
                return true
              rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH => error
                @error = error
                return false
              end
            end
          rescue Timeout::Error => error
            @error = error
            return false
          end
        end
    end
  end
end
