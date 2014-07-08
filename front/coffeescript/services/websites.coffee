window.application.service 'websites', ($q, websocket, userAuthorizer) ->
    
    model =
        isListing: yes
        list: []
        
    list = () ->
        console.info 'waitress is listing websites'
            
        request = {}
        
        userAuthorizer.addAuthorizationTo request
                
        websocket.emit websocket.events.waitress.website.list, request
        websocket.on websocket.events.waitress.website.list, (response) ->
            model.isListing = yes
            model.list = response.result
            model.isListing = no
            
            console.info 'waitress has listed websites'
    
    create = (repository) ->
        if !repository then throw 'you need to provide data'
        
        deferred = $q.defer()
        parts = repository.split '/'
        
        request =
            repository:
                author: parts[0]
                name: parts[1]
            
        userAuthorizer.addAuthorizationTo request
        
        console.info 'waitress is creating a website'
        
        websocket.emit websocket.events.waitress.website.create, request
        websocket.on websocket.events.waitress.website.create, (response) ->
            website =
                repository:
                    author: request.repository.author
                    name: request.repository.name
            
            model.list.push website
            deferred.resolve website
            
            console.info 'waitress has created a website from repository %s', repository
        
        deferred.promise

    do list
    
    exposed =
        model: model
        create: create
        list: list