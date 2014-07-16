window.application.controller 'userAuthorize', ($scope, $q, user, websocket) ->
    $scope.user = user.model
    $scope.websocket = websocket.model
    
    $scope.isAuthorizing = no
    
    $scope.numberOfFailures = 0

    $scope.form =
        name: ''
        password: ''
        
    $scope.authorize = () ->
        $scope.isAuthorizing = yes
        
        $q
            .when user.authorize $scope.form
            .then () ->
                $scope.isAuthorizing = no
                $scope.numberOfFailures = 0
                $scope.form.password = ''
            .catch () ->
                $scope.isAuthorizing = no
                $scope.numberOfFailures += 1