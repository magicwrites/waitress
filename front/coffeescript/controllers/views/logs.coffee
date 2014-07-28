window.application.controller 'logs', ($scope, $routeParams, websocket, userAuthorizer) ->
    $scope.logs = [] 
    
    request =
        limit: $routeParams.limit || 128
    
    userAuthorizer.addAuthorizationTo request
    
    websocket.emit 'waitress log list', request
    
    websocket.only 'waitress log list', (response) ->
        console.info 'retrieved logs list, counted %s elements', response.result.length
        
        $scope.logs = response.result