window.application.service 'websites', ($q, websocket, user) ->
    
    model = []
        
    # mock
    
#    model.push { repository: 'magicwrites/partofuniverse', public: '1.12.0', latest: '1.24.5' }
#    model.push { repository: 'magicwrites/personal-website', public: '0.1.0', latest: '0.21.1' }
    
    create = (repository) ->
        deferred = $q.defer()
        
        data =
            user: user.model.user
            repository: repository
        
        websocket.socket.emit websocket.events.waitress.website.create, data
        websocket.socket.on websocket.events.waitress.website.create, (website) ->
            model.push website
            
            deferred.resolve website
            
            console.info 'waitress has created a website from repository %s', repository
        
        deferred.promise
    
    exposed =
        model: model
        create: create