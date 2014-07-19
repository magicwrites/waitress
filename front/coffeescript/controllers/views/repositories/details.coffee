window.application.controller 'repositoriesDetails', ($scope, $routeParams, $location, userAuthorizer, websocket) ->
    $scope.states =
        isRemovalDisabled: yes
        isInitializing: yes
        isRemoving: no
    
    $scope.remove = () ->
        console.info 'attempting to remove a repository %s', $routeParams.id
        
        $scope.states.isRemoving = yes
        
        request =
            repository:
                _id: $routeParams.id
            
        userAuthorizer.addAuthorizationTo request
        
        websocket.emit 'waitress repository remove', request
        websocket.on   'waitress repository remove', (response) ->
            if  response.error
                $scope.states.isError = yes
                console.error 'there was an error during removal of a repository: %s', response.error
            else 
                $scope.states.isRemoving = no
                console.info 'a repository was removed successfuly'
                $location.path 'repositories'
                
    do () ->
        request =
            repository:
                _id: $routeParams.id

        userAuthorizer.addAuthorizationTo request

        websocket.emit 'waitress repository get', request
        websocket.on   'waitress repository get', (response) ->
            console.info 'retrieved repository details'

            $scope.states.isInitializing = no
            $scope.repository = response.result