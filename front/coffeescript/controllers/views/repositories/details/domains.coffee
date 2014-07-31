window.application.controller 'repositoriesDetailsDomains', ($scope, $routeParams, userAuthorizer, websocket) ->
    $scope.states =
        isListing: yes
        isCreating: no
        isRemoving: no
        isError: no
        
    $scope.form =
        name: ''

    request =
        repository:
            _id: $routeParams.id

    userAuthorizer.addAuthorizationTo request
    
    websocket.emit 'waitress domain list', request
    
    websocket.only 'waitress domain list', (response) ->
        $scope.states.isListing = no

        if  response.error
            $scope.states.isError = yes
            console.error 'there was an error during listing of the domains: %s', response.error
        else 
            $scope.domains = response.result
            console.info 'a domain list has been retrieved'
    
    $scope.create = () ->
        console.info 'create a domain for repository %s', $routeParams.id
        
        $scope.isCreating = yes
        
        request =
            domain:
                name: $scope.form.name
            repository:
                _id: $routeParams.id

        userAuthorizer.addAuthorizationTo request
        
        websocket.emit 'waitress domain create', request
        
    websocket.only 'waitress domain create', (response) ->
        $scope.states.isCreating = no

        if  response.error
            $scope.states.isError = yes
            console.error 'there was an error during creation of a domain: %s', response.error
        else
            console.info 'a domain has been created successfuly'
            $scope.form.name = ''
            
        websocket.emit 'waitress domain list', request
        
    $scope.remove = (domainIdentifier) ->
        console.info 'removing a domain for repository %s', $routeParams.id
        
        $scope.isRemoving = yes
        
        request =
            domain:
                _id: domainIdentifier
            repository:
                _id: $routeParams.id

        userAuthorizer.addAuthorizationTo request
        
        websocket.emit 'waitress domain remove', request
        
    websocket.only 'waitress domain remove', (response) ->
        $scope.states.isRemoving = no

        if  response.error
            $scope.states.isError = yes
            console.error 'there was an error during removal of a domain: %s', response.error
        else
            console.info 'a domain has been removed successfuly'
            
        websocket.emit 'waitress domain list', request
        