window.application.controller 'websites', ($scope, websites) ->
    $scope.websites = websites.model
    
    $scope.isCreating = no
    
    $scope.create = () ->
        $scope.isCreating = yes
        
        websites.create $scope.newRepository
            .then () ->
                $scope.isCreated = yes
                $scope.isCreating = no
            .catch () ->
                $scope.isCreated = no
                $scope.isCreating = no