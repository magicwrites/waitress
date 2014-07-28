window.application.controller 'repositoriesDetailsVersions', ($scope, $routeParams, userAuthorizer, websocket) ->
    $scope.states =
        isPulling: no
        isPublishing: no
        isError: no
        
    request =
        repository:
            _id: $routeParams.id

    userAuthorizer.addAuthorizationTo request
    
    $scope.pull = () ->
        console.info 'pulling a latest version of the repository'
        
        $scope.states.isPulling = yes
        
        websocket.emit 'waitress repository pull', request
    
    $scope.publish = () ->
        console.info 'publishing a latest version of the repository'
        
        $scope.states.isPublishing = yes
        
        websocket.emit 'waitress repository publish', request
        
    websocket.only 'waitress repository pull', (response) ->
        $scope.states.isPulling = no

        if  response.error
            $scope.states.isError = yes
            console.error 'there was an error during pulling of a repository: %s', response.error
        else 
            console.info 'a repository was pulled successfuly'

        websocket.emit 'waitress repository get', request

    websocket.only 'waitress repository publish', (response) ->
        $scope.states.isPublishing = no

        if  response.error
            $scope.states.isError = yes
            console.error 'there was an error during publishing of a repository: %s', response.error
        else 
            console.info 'a repository was published successfuly'

        websocket.emit 'waitress repository get', request