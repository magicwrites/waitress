window.application.controller 'repositories', ($scope, websocket, userAuthorizer) ->
    $scope.repositories = []
    
    request = {}
    
    userAuthorizer.addAuthorizationTo request
    
    websocket.emit 'waitress repository list', request
    
    websocket.only 'waitress repository list', (response) ->
        console.info 'retrieved repositories list, counted %s elements', response.result.length
        
        $scope.repositories = response.result