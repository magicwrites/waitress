window.application.config ($routeProvider) ->
    $routeProvider.when '/home',
        templateUrl: 'templates/views/home.html'
    $routeProvider.when '/roadmap',
        templateUrl: 'templates/views/roadmap.html'
    $routeProvider.when '/authorization',
        controller: 'authorization'
        templateUrl: 'templates/views/authorization.html'
        
    $routeProvider.when '/services',
        templateUrl: 'templates/views/services.html'
        isRestricted: yes
    $routeProvider.when '/websites',
        templateUrl: 'templates/views/websites.html'
        controller: 'websites'
        isRestricted: yes
    $routeProvider.when '/websites/:website',
        templateUrl: 'templates/views/websites/details.html'
        isRestricted: yes
        
    $routeProvider.otherwise
        redirectTo: '/home'