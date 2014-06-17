window.application.service 'user', ($q, $timeout) ->
    
    model =
        isAuthorized: no
        isCreated: no
    
    authorize = (form) ->
        deferred = $q.defer()
        
        pretend = () ->
            model.isAuthorized = yes
            deferred.resolve();
        
        $timeout pretend, 1000
        
        deferred.promise
        
    deauthorize = () ->
        model.isAuthorized = no
        
    create = (form) ->
        deferred = $q.defer()
        
        pretend = () ->
            model.isCreated = yes
            model.isAuthorized = yes
            deferred.resolve()
            
        $timeout pretend, 1000
        
        deferred.promise
    
    exposed =
        model: model
        authorize: authorize
        deauthorize: deauthorize
        create: create