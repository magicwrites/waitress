window.application.service 'user', ($q, $timeout, $rootScope, websocket) ->
    
    model =
        isAuthorized: no
        isCreated: no
        user:
            username: ''
            password: ''
            
    # private
    
    setUserFrom = (form) ->
        model.user.username = form.username
        model.user.password = window.md5 form.password
            
    $rootScope.$on 'connect', () ->
        websocket.socket.emit 'waitress user isCreated'
        websocket.socket.on 'waitress user isCreated', (isCreated) ->
            model.isCreated = isCreated
            $rootScope.$apply()
            
            console.info 'waitress user existence informations has been retrieved'
            
    # public
    
    authorize = (form) ->
        deferred = $q.defer()
        
        setUserFrom form
        
        websocket.socket.emit 'waitress user isAuthorized', model.user
        websocket.socket.on 'waitress user isAuthorized', (isAuthorized) ->
            model.isAuthorized = isAuthorized
            
            if isAuthorized then deferred.resolve() else deferred.reject()
                
            console.info 'waitress has received user authorization response - ' + isAuthorized
        
        deferred.promise
        
    deauthorize = () ->
        model.isAuthorized = no
        
    create = (form) ->
        deferred = $q.defer()
        
        setUserFrom form
        
        websocket.socket.emit 'waitress user create', model.user
        websocket.socket.on 'waitress user create', () ->
            model.isAuthorized = yes
            model.isCreated = yes
            deferred.resolve()
            
            console.info 'waitress has created an user authorization data'
        
        deferred.promise
    
    exposed =
        model: model
        authorize: authorize
        deauthorize: deauthorize
        create: create