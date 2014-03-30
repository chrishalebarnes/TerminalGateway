module TerminalGateway
  require 'net/ssh'

  # Starts Net::SSH in a new thread with a user shell.
  # Exposes methods useful for a terminal emulator
  class TerminalGateway
    attr_accessor :connection_thread

    def open(host)
      mutex = Mutex.new
      @connection_thread = Thread.new do
        if host.private_key != nil && host.private_key != ""
          open_params = { :port => host.port, :key_data => host.private_key, :keys_only => true }
        else
          open_params = { :password => host.password, :port => host.port }
        end

        Net::SSH.start(host.host, host.user_name, open_params) do |ssh|
          ssh.open_channel do |ch|

            ch.request_pty({:chars_wide => host.width, :chars_high => host.height}) { |pty, success| raise "Could not get pty" unless success }

            ch.send_channel_request "shell" do |shell, success|
              raise "Could not get shell" unless success

              shell.on_data { |ch_on_data, data| write data }
              shell.on_extended_data { |ch_on_extended_data, type, data| write data }
              shell.on_close { |ch_on_close| @close_method.call }

              shell.on_process do |ch_on_proc|
                mutex.synchronize do
                  ch_on_proc.send_data @input unless @input.nil?
                  @input = nil
                end
              end
            end
          end
          ssh.loop { channel.active? }
        end
      end
    end

    # Sends "exit\n" since the ssh session is a user shell
    def close
      queue_input "exit\n"
    end

    # Queues input between ssh.loop event loops
    # Input gets sent as soon as @input is not nil
    def queue_input(input)
      @input = !@input.nil? ? @input += input : input
    end

    # Uses whatever method is given to on_data to write stdout somewhere
    def write(data)
      @write_method.call data
    end

    def on_data(&write_method)
      @write_method = write_method
    end

    def on_close(&close_method)
      @close_method = close_method
    end    
  end
end