require "test/unit"
require './lib/terminal_gateway'
require './lib/host'
 
class TerminalGatewayTest < Test::Unit::TestCase
 
  # News up TerminalGateway, opens and closes a connection
  # Only tests that nothing catastrophic has happened
  # ToDo: Find a better way to test the thread and events
  def test_catastrophe
    terminal_gateway = TerminalGateway::TerminalGateway.new
    assert_not_nil(terminal_gateway)

    host_name = "10.0.0.5"
    port = 22
    user_name = "vagrant"
    password = "vagrant"
    height = 40
    width = 80

    host = TerminalGateway::Host.new(host_name, port, user_name, password, nil, width, height)
    assert_not_nil(host)

    assert_nothing_raised do
      terminal_gateway.open(host)
    end

    assert_equal(true, terminal_gateway.connection_thread.alive?)
    
    terminal_gateway.on_data do |data|
    end

    terminal_gateway.on_close do
    end

    assert_nothing_raised do
      terminal_gateway.queue_input("ls")
    end
  end 
end