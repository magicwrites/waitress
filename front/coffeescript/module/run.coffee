window.application.run ($rootScope, $location, user) ->
    $rootScope.getSvgFrom = (location) ->
        templateLocation = 'images/' + location + '.svg'
        
    $rootScope.getTemplateFrom = (location) ->
        templateLocation = 'templates/' + location + '.html'
        
    $rootScope.dateFormats =
        datetime: 'HH:mm:ss - dd MMMM yyyy'
        date: 'HH:mm:ss'
        time: 'yyyy-MM-dd'

    $rootScope.$on '$routeChangeStart', (event, nextRoute) ->
        if nextRoute.isRestricted and !user.model.isAuthorized then $location.path 'user/authorize'