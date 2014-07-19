window.application.controller 'repositoriesNew', ($scope, $location, websocket, userAuthorizer) ->
    $scope.states =
        isError: no
        isCreating: no
    
    $scope.form =
        author: ''
        name: ''
            
    $scope.create = () ->
        console.info 'attempting to create new repository with author %s and name %s', $scope.form.author, $scope.form.name
        
        $scope.states.isCreating = yes
        
        request =
            repository: $scope.form
            
        userAuthorizer.addAuthorizationTo request
        
        websocket.emit 'waitress repository create', request
        websocket.on   'waitress repository create', (response) ->
            if  response.error
                $scope.states.isError = yes
                console.error 'there was an error during creation of a repository: %s', response.error
            else 
                $scope.states.isCreating = no
                console.info 'a repository was created successfuly'
                $location.path 'repositories'