window.application.controller 'userCreate', ($scope, $q, user, websocket) ->
    $scope.user = user.model
    $scope.websocket = websocket.model
    
    $scope.isCreating = no
    $scope.isAuthorizing = no
    
    $scope.failedAuthorizations = 0

    $scope.forms =
        create:
            name: ''
            password: ''
        authorize:
            name: ''
            password: ''

    $scope.create = () ->
        $scope.isCreating = yes
        
        $q
            .when user.create $scope.forms.create
            .then () ->
                $scope.isCreating = no
                $scope.forms.create.password = ''
        
    $scope.authorize = () ->
        $scope.isAuthorizing = yes
        
        $q
            .when user.authorize $scope.forms.authorize
            .then () ->
                $scope.isAuthorizing = no
                $scope.failedAuthorizations = 0
                $scope.forms.authorize.password = ''
            .catch () ->
                $scope.isAuthorizing = no
                $scope.failedAuthorizations += 1
        
    $scope.deauthorize = () ->
        user.deauthorize()