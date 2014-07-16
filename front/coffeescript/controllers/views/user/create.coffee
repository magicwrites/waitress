window.application.controller 'userCreate', ($scope, $q, user, websocket) ->
    $scope.user = user.model
    $scope.websocket = websocket.model
    
    $scope.isCreating = no
    
    $scope.form =
        name: ''
        password: ''

    $scope.create = () ->
        $scope.isCreating = yes
        
        $q
            .when user.create $scope.form
            .then () ->
                $scope.isCreating = no
                $scope.form.password = ''