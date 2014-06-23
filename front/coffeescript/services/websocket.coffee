window.application.service 'websocket', ($rootScope, websocketEvents) ->
    
    model =
        isConnected: no
        protocol: 'http'
        host: 'localhost'
        port: 2001
        
    set = (data) ->
        model.protocol = data.protocol
        model.host = data.host
        model.port = data.port
    
    socketDestination = model.protocol + '://' + model.host + ':' + model.port
    socket = io.connect socketDestination
    
    socket.on websocketEvents.model.connect, () ->
        model.isConnected = yes
        $rootScope.$apply()
        $rootScope.$broadcast websocketEvents.connect
        console.info 'service of websocket has connected'
        
    socket.on websocketEvents.model.disconnect, () ->
        model.isConnected = no
        $rootScope.$apply()
        $rootScope.$broadcast websocketEvents.disconnect
        console.info 'service of websocket has disconnected'
    
    exposed =
        model: model
        events: websocketEvents.model
        set: set
        socket: socket
    