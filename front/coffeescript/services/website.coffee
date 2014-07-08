window.application.service 'website', ($q, websocket, userAuthorizer, websites, $rootScope) ->
    
    model =
        isLoading: yes
        isRemoved: no
        repository:
            author: undefined
            name: undefined
        ports:
            latest: undefined
            public: undefined
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
        
        request =
            repository: model.repository
            
        userAuthorizer.addAuthorizationTo request
        
        websocket.emit websocket.events.waitress.website.get, request
        websocket.on websocket.events.waitress.website.get, (website) ->
            model.isLoading = no
            
            model.repository =
                author: author
                name: name
            
            model.versions =
                latest: website.versions.latest
                public: website.versions.public
                stored: website.versions.stored
                
            model.domains = website.domains
            model.ports = website.ports
            
            console.info 'waitress has loaded data for website %s/%s', model.repository.author, model.repository.name

    remove = () ->
        deferred = $q.defer()
        
        model.isLoading = yes
        
        request =
            repository: model.repository
            
        userAuthorizer.addAuthorizationTo request
        
        websocket.emit websocket.events.waitress.website.remove, request
        websocket.on websocket.events.waitress.website.remove, (response) ->
            model.isRemoved = yes
            model.isLoading = no
            websites.list()
            
            deferred.resolve response
            
            console.info 'waitress has removed a %s/%s website', model.repository.author, model.repository.name
        
        deferred.promise
    
    exposed =
        model: model
        get: get
        remove: remove