window.application.run ($rootScope, $location, user) ->
    $rootScope.getSvgFrom = (location) ->
        templateLocation = 'images/' + location + '.svg'
        
    $rootScope.getTemplateFrom = (location) ->
        templateLocation = 'templates/' + location + '.html'

    $rootScope.$on '$routeChangeStart', (event, nextRoute) ->
        if nextRoute.isRestricted and !user.model.isAuthorized then $location.path 'user/authorize'