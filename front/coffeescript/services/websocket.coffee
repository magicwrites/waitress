window.application.service 'websocket', ($rootScope) ->
    
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
    
    socket.on 'connect', () ->
        model.isConnected = yes
        $rootScope.$apply()
        $rootScope.$broadcast 'connect'
        console.info 'service of websocket has connected'
        
    socket.on 'disconnect', () ->
        model.isConnected = no
        $rootScope.$apply()
        $rootScope.$broadcast 'disconnect'
        console.info 'service of websocket has disconnected'
    
    exposed =
        model: model
        set: set
        socket: socket
    