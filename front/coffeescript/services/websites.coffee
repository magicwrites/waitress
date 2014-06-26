window.application.service 'websites', ($q, websocket, userAuthorizer) ->
    
    model =
        isListing: yes
        list: []
        
    list = () ->
        console.info 'waitress is listing websites'
            
        requestData = {}
        
        userAuthorizer.addAuthorization requestData
                
        websocket.emit websocket.events.waitress.website.list, requestData
        websocket.on websocket.events.waitress.website.list, (websites) ->
            model.isListing = yes
            model.list = websites
            model.isListing = no
            
            console.info 'waitress has listed websites'
    
    create = (repository) ->
        deferred = $q.defer()
        
        requestData =
            repository: repository
            
        userAuthorizer.addAuthorization requestData
        
        websocket.emit websocket.events.waitress.website.create, requestData
        websocket.on websocket.events.waitress.website.create, (website) ->
            model.list.push website
            
            deferred.resolve website
            
            console.info 'waitress has created a website from repository %s', repository
        
        deferred.promise

    do list
    
    exposed =
        model: model
        create: create
        list: list