window.application.service 'user', ($q, $rootScope, $location, websocket, userSession) ->
    
    emptyUserModel =
        name: ''
        password: ''
    
    model =
        isAuthorized: userSession.model.isSet
        isCreated: userSession.model.isSet
        isConnected: no
        user: if userSession.model.isSet then userSession.get() else emptyUserModel
        initialization: $q.defer()
            
    # private
    
    setUserFrom = (form) ->
        model.user.name = form.name
        model.user.password = window.md5 form.password
        
    $rootScope.$on websocket.events.disconnect, () ->
        model.isConnected = no
            
    $rootScope.$on websocket.events.connect, () ->
        model.isConnected = yes
        
        websocket.emit websocket.events.waitress.user.isCreated
        websocket.on websocket.events.waitress.user.isCreated, (response) ->
            isCreated = response.result
            if not isCreated then userSession.remove()
            
            model.isCreated = isCreated
            model.initialization.resolve()
            
            if isCreated and not model.isAuthorized then $location.path 'user/authorize'
            
            console.info 'waitress user existence informations has been retrieved'
            
    # public
    
    authorize = (form) ->
        deferred = $q.defer()
        
        setUserFrom form
        
        request =
            user: model.user
        
        websocket.emit websocket.events.waitress.user.isAuthorized, request
        websocket.on websocket.events.waitress.user.isAuthorized, (response) ->
            isAuthorized = response.result
            model.isAuthorized = isAuthorized

            if isAuthorized then userSession.setFrom model.user
            if isAuthorized then $location.path 'user'
            if isAuthorized then deferred.resolve() else deferred.reject()
                
            console.info 'waitress has received user authorization response - %s', isAuthorized
        
        deferred.promise
        
    deauthorize = () ->
        model.user = emptyUserModel
        $location.path 'user/authorize'
        model.isAuthorized = no
        userSession.remove()
        
    create = (form) ->
        deferred = $q.defer()
        
        setUserFrom form
        
        request =
            user: model.user
        
        websocket.emit websocket.events.waitress.user.create, request
        websocket.on websocket.events.waitress.user.create, () ->
            model.isAuthorized = yes
            model.isCreated = yes
            userSession.setFrom form
            
            deferred.resolve()
            
            console.info 'waitress has created an user authorization data'
        
        deferred.promise
    
    exposed =
        model: model
        authorize: authorize
        deauthorize: deauthorize
        create: create