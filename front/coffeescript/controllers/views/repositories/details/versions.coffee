window.application.controller 'repositoriesDetailsVersions', ($scope, $routeParams, userAuthorizer, websocket) ->
    $scope.states =
        isPulling: no
        isError: no
    
    $scope.pull = () ->
        console.info 'pull a latest version of the repository'
        
        $scope.states.isPulling = yes
        
        request =
            repository:
                _id: $routeParams.id
                
        userAuthorizer.addAuthorizationTo request
        
        websocket.emit 'waitress repository pull', request
        websocket.on   'waitress repository pull', (response) ->
            $scope.states.isPulling = no
            
            if  response.error
                $scope.states.isError = yes
                console.error 'there was an error during pulling of a repository: %s', response.error
            else 
                console.info 'a repository was pulled successfuly'
                
            websocket.emit 'waitress repository get', request