window.application.controller 'home', ($scope, $location, user) ->
    $scope.user = user.model
    
    if user.model.isCreated and not user.model.isAuthorized then $location.path 'user/authorize'