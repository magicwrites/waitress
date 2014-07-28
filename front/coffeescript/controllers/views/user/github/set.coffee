window.application.controller 'userGithubSet', ($scope, github, websocket) ->
    $scope.github = github.model
    
    $scope.form =
        username: github.model.data.username || ''
        password: github.model.data.password || ''
        
    $scope.set = () ->
        github.set $scope.form
        
    websocket.only 'waitress github isSet', (response) ->
        if response.result then $scope.form = response.result