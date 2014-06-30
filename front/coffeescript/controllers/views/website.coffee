window.application.controller 'website', ($scope, $routeParams, website, websocket) ->
    
    $scope.repository =
        author: $routeParams.repositoryauthor
        name: $routeParams.repositoryname
    
    $scope.isRemoved = no
    $scope.websiteState = website.state
    $scope.website = website.model
    $scope.remove = website.remove
    
    websocket.on websocket.events.waitress.website.remove, () ->
        $scope.isRemoved = yes
        
    website.get $scope.repository.author, $scope.repository.name