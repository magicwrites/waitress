window.application.service 'websocketEvents', () ->
    
    model =
        connect: 'connect'
        disconnect: 'disconnect'
        waitress:
            user:
                isConnected: 'waitress user isConnected'
                isCreated: 'waitress user isCreated'
                isAuthorized: 'waitress user isAuthorized'
                create: 'waitress user create'
    
    exposed =
        model: model