Bundler.require
require 'sinatra'
require 'sinatra/base'
require 'rack/csrf'

#Change this to your own secret
use Rack::Session::Cookie, :secret => '8_KVa<L$T;k@4%&z)J_d[Sw<[yF#ReNR6],ymzvLm^2WzH~I}I4C`bfXIE}[N5S'
use Rack::Csrf, :raise => true

set :server, 'thin'

require './app'

run TerminalGateway::App