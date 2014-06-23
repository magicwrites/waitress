window.application.service 'websocketEvents', () ->
    
    model =
        waitress:
            user:
                isConnected: 'waitress user isConnected'
                isCreated: 'waitress user isCreated'
                isAuthorized: 'waitress user isAuthorized'
                create: 'waitress user create'
        connect: 'connect'
        disconnect: 'disconnect'
    
    exposed =
        model: model
        