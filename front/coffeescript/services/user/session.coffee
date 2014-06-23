window.application.service 'userSession', () ->
    
    model =
        isSet: if window.localStorage.getItem 'user' then yes else no
    
    # public
    
    get = () ->
        storedUser = window.localStorage.getItem 'user'
        storedUser = JSON.parse storedUser
        
    setFrom = (model) ->
        user = JSON.stringify model
        window.localStorage.setItem 'user', user
        model.isPresent = yes
        
    remove = () ->
        window.localStorage.removeItem 'user'
        model.isPresent = no
        
    # exposed
    
    exposed =
        model: model
        get: get
        setFrom: setFrom
        remove: remove