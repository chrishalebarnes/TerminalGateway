require './lib/terminal_gateway'
require './lib/host'

module TerminalGateway
  module Routes
    def self.registered(app)
      app.get "/" do
        erb :index, :layout => :layout
      end

      app.get "/terminal" do
        raise "CSRF token in the request did not match the known token" unless params[Rack::Csrf.field] == Rack::Csrf.csrf_token(env)
        raise "Not a WebSocket request." unless request.websocket?

        if request.websocket?
          host_name = params[:host]
          port = params[:port].to_i
          user_name = params["user-name"]
          password = params[:password]
          private_key = params["private-key"]
          height = params[:height].to_i
          width = params[:width].to_i

          terminal_gateway = TerminalGateway.new
          host = Host.new(host_name, port, user_name, password, private_key, width, height)
          terminal_gateway.open(host)

          request.websocket do |ws|
            terminal_gateway.on_data do |data|
              ws.send data
            end

            terminal_gateway.on_close do
              ws.close_connection
            end        

            ws.onopen do
              #Associate each session with a websocket to prevent issues with multiple browsers
              socket_session = { session_id: session[:session_id], socket: ws }
              settings.sockets << socket_session
            end

            ws.onmessage do |msg|
              EM.next_tick { 
                settings.sockets.each { |s|
                  if(s[:session_id] == session[:session_id])
                    terminal_gateway.queue_input msg
                  end
                } 
              }
            end

            ws.onclose do
              socket_session = { session_id: session[:session_id], socket: ws }
              settings.sockets.delete(socket_session)
            end
          end      
        end
      end
    end
  end
end