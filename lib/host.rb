module TerminalGateway
  class Host
    attr_accessor :host
    attr_accessor :port
    attr_accessor :user_name
    attr_accessor :password
    attr_accessor :private_key
    attr_accessor :width
    attr_accessor :height

    def initialize(host, port, user_name, password, private_key, width, height)
      @host = host
      @port = port
      @user_name = user_name
      @password = password
      @private_key = private_key
      @width = width
      @height = height
    end
  end
end