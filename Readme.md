Terminal Gateway
================

![Example Screenshot. Displays an Ubuntu terminal in a browser.](https://github.com/chrishalebarnes/terminal-gateway/blob/master/example.png?raw=true)

An SSH terminal in a browser. This is currently a proof of concept. It uses [term.js](http://github.com/chjj/term.js) on the front end to communicate with [Sinatra](https://github.com/sinatra/sinatra) on the backend using websockets.

## Getting Started
Install the depenencies

    bundle install

If a server to SSH into is needed there is a Vagrantfile that will spin one up. See more on [Vagrant](https://github.com/mitchellh/vagrant)

    vagrant up

Start the web server

    rackup

Visit localhost:9292 in a browser

##License and Copyright

See [LICENSE](https://github.com/chrishalebarnes/TerminalGateway/blob/master/LICENSE)