window.application.controller 'user', ($scope, user, github) ->
    $scope.user = user.model
    $scope.github = github.model
        
    $scope.deauthorize = () ->
        user.deauthorize()