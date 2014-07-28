window.application.controller 'repositoriesDetails', ($scope, $routeParams, $location, userAuthorizer, websocket) ->
    $scope.states =
        isRemovalDisabled: yes
        isInitializing: yes
        isRemoving: no
        
    request =
        repository:
            _id: $routeParams.id

    userAuthorizer.addAuthorizationTo request
    
    $scope.remove = () ->
        console.info 'attempting to remove a repository %s', $routeParams.id
        
        $scope.states.isRemoving = yes
        
        websocket.emit 'waitress repository remove', request
                
    do () ->
        websocket.emit 'waitress repository get', request
        
    websocket.only 'waitress repository remove', (response) ->
        $scope.states.isRemoving = no

        if  response.error
            $scope.states.isError = yes
            console.error 'there was an error during removal of a repository: %s', response.error
        else 
            console.info 'a repository was removed successfuly'
            $location.path 'repositories'
        
    websocket.only 'waitress repository get', (response) ->
        console.info 'retrieved repository details'

        $scope.states.isInitializing = no
        $scope.repository = response.result