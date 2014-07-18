window.application.controller 'websitesNew', ($scope, $location, websocket, userAuthorizer) ->
    $scope.states =
        isError: no
        isCreating: no
    
    $scope.form =
        repository:
            author: ''
            name: ''
            
    $scope.create = () ->
        console.info 'attempting to create new website based on repository %s/%s', $scope.form.repository.author, $scope.form.repository.name
        
        $scope.states.isCreating = yes
        
        request =
            repository: $scope.form.repository
            
        userAuthorizer.addAuthorizationTo request
        
        websocket.emit 'waitress website create', request
        websocket.on   'waitress website create', (response) ->
            if  response.error
                $scope.states.isError = yes
                console.error 'there was an error during creation of a website: %s', response.error
            else 
                $scope.states.isCreating = no
                console.info 'a website was created successfuly'
                $location.path 'websites'
        
        