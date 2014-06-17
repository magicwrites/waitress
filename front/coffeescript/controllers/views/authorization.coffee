window.application.controller 'authorization', ($scope, $q, user) ->
    $scope.user = user.model
    
    $scope.isCreating = no
    $scope.isAuthorizing = no

    $scope.forms =
        create:
            username: ''
            password: ''
        authorize:
            username: ''
            password: ''

    $scope.create = () ->
        $scope.isCreating = yes
        
        $q
            .when user.create $scope.forms.create
            .then () ->
                console.log 'created', $scope.model
                $scope.isCreating = no
        
    $scope.authorize = () ->
        $scope.isAuthorizing = yes
        
        $q
            .when () ->
                user.authorize $scope.forms.authorize
            .then () ->
                $scope.isAuthorizing = no
            .fail () ->
                $scope.isAuthorizing = no
                
            # finally instead of then & fail ?
        
    $scope.deauthorize = () ->
        user.deauthorize()