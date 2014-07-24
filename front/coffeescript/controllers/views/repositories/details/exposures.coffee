window.application.controller 'repositoriesDetailsExposures', ($scope, $routeParams, websocket, userAuthorizer) ->
    $scope.states =
        isHiding: no
        isExposing: no
        isError: no
                
    $scope.expose = () ->
        console.info 'exposing a repository through nginx service'
        
        $scope.states.isExposing = yes
        
        request =
            repository:
                _id: $routeParams.id
                
        userAuthorizer.addAuthorizationTo request
        
        websocket.emit 'waitress repository expose', request
        websocket.on   'waitress repository expose', (response) ->
            $scope.states.isExposing = no
            
            if  response.error
                $scope.states.isError = yes
                console.error 'there was an error during exposure of a repository: %s', response.error
            else 
                console.info 'a repository was exposed successfuly'
                
            websocket.emit 'waitress repository get', request
                
    $scope.hide = () ->
        console.info 'hiding a repository previously exposed through nginx service'
        
        $scope.states.isHiding = yes
        
        request =
            repository:
                _id: $routeParams.id
                
        userAuthorizer.addAuthorizationTo request
        
        websocket.emit 'waitress repository hide', request
        websocket.on   'waitress repository hide', (response) ->
            $scope.states.isHiding = no
            
            if  response.error
                $scope.states.isError = yes
                console.error 'there was an error during hiding of a repository: %s', response.error
            else 
                console.info 'a repository was hidden successfuly'
                
            websocket.emit 'waitress repository get', request