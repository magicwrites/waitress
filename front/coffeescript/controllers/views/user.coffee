window.application.controller 'user', ($scope, user) ->
    $scope.user = user.model
        
    $scope.deauthorize = () ->
        user.deauthorize()