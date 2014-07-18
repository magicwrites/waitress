window.application.controller 'websites', ($scope, websocket, userAuthorizer) ->
    $scope.websites = []
    
    request = {}
    
    userAuthorizer.addAuthorizationTo request
    
    websocket.emit 'waitress website list', request
    websocket.on   'waitress website list', (response) ->
        console.info 'retrieved websites list, counted %s elements', response.result.length
        
        $scope.websites = response.result