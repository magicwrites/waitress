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
            website:
                create: 'waitress website create'
                list: 'waitress website list'
                get: 'waitress website get'
                remove: 'waitress website remove'
    
    exposed =
        model: model