window.application.config ($routeProvider) ->
    $routeProvider.when '/home',
        templateUrl: 'templates/views/home.html'
    $routeProvider.when '/roadmap',
        templateUrl: 'templates/views/roadmap.html'
        
    $routeProvider.otherwise
        redirectTo: '/home'