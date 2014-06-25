window.application.controller 'websitesDetails', ($scope, $routeParams) ->
    
    $scope.repository =
        author: $routeParams.repositoryauthor
        name: $routeParams.repositoryname