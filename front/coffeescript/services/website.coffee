window.application.service 'website', ($q, websocket, userAuthorizer, websites, $rootScope) ->
    
    model =
        isLoading: yes
        isRemoved: no
        repository:
            author: null
            name: null
        versions:
            latest: ''
            public: ''
            stored: []
        domains: []
            
    get = (author, name) ->
        console.info 'website is loading data for website %s/%s', author, name
        
        model.isLoading = yes
        model.repository.author = author
        model.repository.name = name
        
        deferred = $q.defer()
        
        requestData =
            repository: model.repository
            
        userAuthorizer.addAuthorization requestData
        
        websocket.emit websocket.events.waitress.website.get, requestData
        websocket.on websocket.events.waitress.website.get, (website) ->
            model.isLoading = no
            
            deferred.resolve website
            
            console.info 'waitress has loaded data for website %s/%s', model.repository.author, model.repository.name
        
        deferred.promise

    remove = () ->
        deferred = $q.defer()
        
        model.isLoading = yes
        
        requestData =
            repository: model.repository
            
        userAuthorizer.addAuthorization requestData
        
        websocket.emit websocket.events.waitress.website.remove, requestData
        websocket.on websocket.events.waitress.website.remove, (website) ->
            model.isRemoved = yes
            model.isLoading = no
            websites.list()
            
            deferred.resolve website
            
            console.info 'waitress has removed a %s/%s website', model.repository.author, model.repository.name
        
        deferred.promise
    
    exposed =
        get: get
        remove: remove