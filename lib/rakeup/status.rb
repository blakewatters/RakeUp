require 'rakeup/utilities'

module RakeUp
  class Status
    attr_reader :pid, :host, :port

    def initialize(pid, host, port)
      @pid = pid
      @host = host
      @port = port
      @process_check = Utilities::ProcessCheck.new(pid)
      @port_check = Utilities::PortCheck.new(host, port)
    end

    def check
      @process_check.run if pid
      @port_check.run
    end

    def running?
      pid && @process_check.running?
    end

    def listening?
      @port_check.open?
    end

    def up?
      running? && listening?
    end

    def host_and_port
      "#{host}:#{port}"
    end

    def to_s
      if up?
        "Found server listening on #{host_and_port} (pid #{pid})"
      else
        if pid
          [@process_check.to_s, @port_check.to_s].join("\n")
        else
          @port_check.to_s
        end
      end
    end
  end
end
