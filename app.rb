require './routes'

module TerminalGateway
  class App < Sinatra::Base
    register Routes
    set :sockets, []
    enable :logging, :dump_errors, :raise_errors, :show_exceptions
  end
end