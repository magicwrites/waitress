window.application.controller 'userGithubSet', ($scope, github, websocket) ->
    $scope.github = github.model
    
    $scope.form =
        username: ''
        password: ''
        
    $scope.set = () ->
        github.set $scope.github.data