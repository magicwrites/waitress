window.application.service 'userSession', () ->
    
    model =
        isSet: if window.localStorage.getItem 'user' then yes else no
    
    # public
    
    console.info 'user session initial presence is resolved to %s', model.isSet
    
    get = () ->
        storedUser = window.localStorage.getItem 'user'
        storedUser = JSON.parse storedUser
        
    setFrom = (model) ->
        user = JSON.stringify model
        window.localStorage.setItem 'user', user
        model.isPresent = yes
        
        console.info 'user session is set with name %s', model.name
        
    remove = () ->
        window.localStorage.removeItem 'user'
        model.isPresent = no
        
        console.info 'user session is cleared'
        
    # exposed
    
    exposed =
        model: model
        get: get
        setFrom: setFrom
        remove: remove