window.application.service 'user', ($q, $timeout, $rootScope, websocket, userSession) ->
    
    emptyUserModel =
        username: ''
        password: ''
    
    model =
        isAuthorized: userSession.model.isSet
        isCreated: userSession.model.isSet
        user: if userSession.model.isSet then userSession.get() else emptyUserModel
        initialization: $q.defer()
            
    # private
    
    setUserFrom = (form) ->
        model.user.username = form.username
        model.user.password = window.md5 form.password
            
    $rootScope.$on websocket.events.connect, () ->
        websocket.emit websocket.events.waitress.user.isCreated
        websocket.on websocket.events.waitress.user.isCreated, (isCreated) ->
            if not isCreated then userSession.remove()
            
            model.isCreated = isCreated
            model.initialization.resolve()
            
            console.info 'waitress user existence informations has been retrieved'
            
    # public
    
    authorize = (form) ->
        deferred = $q.defer()
        
        setUserFrom form
        
        websocket.emit websocket.events.waitress.user.isAuthorized, model.user
        websocket.on websocket.events.waitress.user.isAuthorized, (isAuthorized) ->
            model.isAuthorized = isAuthorized

            if isAuthorized then userSession.setFrom model.user
            if isAuthorized then deferred.resolve() else deferred.reject()
                
            console.info 'waitress has received user authorization response - %s', isAuthorized
        
        deferred.promise
        
    deauthorize = () ->
        model.user = emptyUserModel
        model.isAuthorized = no
        userSession.remove()
        
    create = (form) ->
        deferred = $q.defer()
        
        setUserFrom form
        
        websocket.emit websocket.events.waitress.user.create, model.user
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