window.application.service 'userAuthorizer', (user) ->
    
    addAuthorization = (requestData) ->
        console.info 'user authorizer is adding authorization data with hash - %s', user.model.user.password
        
        requestData.user = user.model.user
    
    exposed =
        addAuthorization: addAuthorization