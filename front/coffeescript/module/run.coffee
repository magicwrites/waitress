window.application.run ($rootScope, $location, user) ->
    $rootScope.getTemplateFrom = (location) ->
        templateLocation = 'templates/' + location + '.html'

    $rootScope.$on '$routeChangeStart', (event, nextRoute) ->
        if nextRoute.isRestricted and !user.model.isAuthorized then $location.path 'authorization'