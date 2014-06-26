window.application.service 'websites', ($q, $rootScope, websocket, userAuthorizer) ->
    
    model =
        isListing: yes
        list: []

    do () ->
        console.info 'waitress is listing websites'
            
        requestData = {}
        
        userAuthorizer.addAuthorization requestData
                
        websocket.socket.emit websocket.events.waitress.website.list, requestData
        websocket.socket.on websocket.events.waitress.website.list, (websites) ->
            model.isListing = yes
            model.list = websites
            model.isListing = no
            
            $rootScope.$apply()
            
            console.info 'waitress has listed websites'
    
    create = (repository) ->
        deferred = $q.defer()
        
        requestData =
            repository: repository
            
        requestData = userAuthorizer.addAuthorization requestData
        
        websocket.socket.emit websocket.events.waitress.website.create, requestData
        websocket.socket.on websocket.events.waitress.website.create, (website) ->
            model.push website
            
            deferred.resolve website
            
            console.info 'waitress has created a website from repository %s', repository
        
        deferred.promise
    
    exposed =
        model: model
        create: create