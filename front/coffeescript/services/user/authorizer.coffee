window.application.service 'userAuthorizer', (user) ->
    
    addAuthorizationTo = (request) ->
        console.info 'user authorizer is adding authorization data with hash - %s', user.model.user.password
        
        request.user = user.model.user
    
    exposed =
        addAuthorizationTo: addAuthorizationTo