var App = App || {};

/**
 * Wraps WebSocket and exposes methods needed for the terminal emulator
 */
App.Socket = function() {
  var webSocket, webSocketUrl, onOpen, onClose, onMessage;

  var connect = function() {
      webSocket = new WebSocket(webSocketUrl);
      webSocket.onopen = onOpen;
      webSocket.onclose = onClose;
      webSocket.onmessage = onMessage; 
  };

  var exit = function() {
    var readyState = webSocket.readyState;

    //readyState 2 is Closing and 3 is closed
    if(webSocket !== undefined && readyState !== 2 && readyState !== 3) {
      webSocket.send("exit\n");
    }
  };

  return {
    init: function(url) {        
      window.onbeforeunload = function(){
        exit();
      };
      webSocketUrl = url;
    },
    connect: connect,
    exit: exit,
    onOpen: function(callback) {
      onOpen = callback;
    },
    onClose: function(callback) {
      onClose = callback;
    },
    onMessage: function(callback) {
      onMessage = callback;
    },
    send: function(data) {
      webSocket.send(data);
    }
  }
}();


/**
 * Represents all the DOM interaction for the page.
 * Exposes events needed for the WebSocket to write and send data
 */
App.View = function() {
  var terminal, onConnect, onMessage, onData, onDisconnect, connectLink, disconnectLink, terminalHeader, terminalElement;

  var init = function(terminalOptions) {
    connectLink = $("a[href*='#connect']");
    disconnectLink = $("a[href*='#disconnect']");
    terminalHeader = $('#terminal-header');
    terminalElement = document.getElementById('terminal');

    $("#connect").submit( function(e) {
      e.preventDefault();
      connect(terminalOptions);
      
      var width = terminalOptions.geometry[0];
      var height = terminalOptions.geometry[1];
      
      e.urlParams = '?' + $(this).serialize() + '&height=' + encodeURIComponent(height) + '&width=' + encodeURIComponent(width);
      onConnect(e);
    });

    $("a[href*='#disconnect']").click( function(e) {
      e.preventDefault();
      disconnect();
    });      
  };

  var hide = function(element) {
    element.addClass('hide');
  };

  var show = function(element) {
    element.removeClass('hide')
  };

  var connect = function(terminalOptions) {
    $('#connect-modal').modal('hide');
    terminalHeader.text($('#user-name').val() + "@" + $('#host').val());
    show(disconnectLink);
    hide(connectLink);
    terminal = new Terminal(terminalOptions);
    terminal.colors[256] = terminalOptions.background;
    terminal.colors[257] = terminalOptions.foreground;
    terminal.open(terminalElement);
    terminal.on('data', onData);
  };

  var disconnect = function() {
    hide(disconnectLink);
    show(connectLink);
    terminal.destroy();
    terminalHeader.text('disconnected');
    onDisconnect();
  }

  return {
    connect: connect,
    disconnect: disconnect,
    init:function(terminalOptions) {
      init(terminalOptions);
    },
    disconnect: disconnect,
    write: function(message)  {
      terminal.write(message.data);
    },
    onConnect: function(callback) {
      onConnect = callback;
    },
    onDisconnect: function(callback) {
      onDisconnect = callback;
    },
    onData: function(callback) {
      onData = callback;
    }
  };
}();

/**
 * Glues App.Socket and App.View together and specifies parameters
 */
App.init = function() {
  //scales the current height and width to character height and width for net-ssh
  // 8 and 20 were chosen by trial and error
  var width = Math.floor(document.documentElement.clientWidth / 8);
  var height = Math.floor(document.documentElement.clientHeight / 20); 

  //options for term.js
  //background and foreground are not in term.js,
  //but added as configuration after newing it up
  var terminalOptions = {
      geometry: [width, height],
      useStyle: true,
      background: '#FFFFFF',
      foreground: '#000000'
  };

  App.View.init(terminalOptions);

  App.View.onConnect(function(e) {
    var url = 'ws://' + window.location.host + window.location.pathname + 'terminal' + e.urlParams; 
    App.Socket.init(url);

    App.Socket.onMessage(function(message) {
      App.View.write(message);
    });

    App.Socket.onClose(function() {
      App.View.disconnect();
    });

    App.Socket.connect();
  });

  App.View.onDisconnect(function(){
    App.Socket.exit();
  });

  App.View.onData(function(data) {
    App.Socket.send(data);
  });
};

$(document).ready(function() {
  App.init();
});