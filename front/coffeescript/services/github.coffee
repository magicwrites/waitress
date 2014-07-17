window.application.service 'github', (websocket, userAuthorizer) ->
    
    model =
        states:
            isInitializing: yes
            isSet: no
            isSetting: no
            isChanged: no
        data:
            username: ''
            password: ''
            
    # initialization
        
    websocket.emit 'waitress github isSet'
    websocket.on   'waitress github isSet', (response) ->
        model.states.isSet = if response.result then yes else no
        model.states.isInitializing = no
        
        if model.states.isSet then model.data = response.result

        console.info 'github setting has been resolved to - %s', model.states.isSet
            
    # public
        
    set = (github) ->
        request =
            github: github
            
        userAuthorizer.addAuthorizationTo request
        
        model.states.isSetting = yes
        
        console.info 'setting github account with data %s and %s', github.username, github.password
        
        websocket.emit 'waitress github set', request
        websocket.on   'waitress github set', (response) ->
            model.states.isSetting = no
            
            if  response.error
                model.states.isSet = no
                console.error 'github account was not set, error occured: %s', error.message
            else
                model.data = response.result
                model.states.isSet = yes
                model.states.isChanged = yes
                console.info 'github account has been set with %s and %s', github.username, github.password
    
    exposed =
        model: model
        set: set