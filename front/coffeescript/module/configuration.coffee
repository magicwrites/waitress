window.application.config ($routeProvider) ->
    $routeProvider.when '/home',
        templateUrl: 'templates/views/home.html'
        controller: 'home'
        
    $routeProvider.when '/user',
        templateUrl: 'templates/views/user.html'
        controller: 'user'
    $routeProvider.when '/user/create',
        templateUrl: 'templates/views/user/create.html'
        controller: 'userCreate'
#    $routeProvider.when '/roadmap',
#        templateUrl: 'templates/views/roadmap.html'
#    $routeProvider.when '/authorization',
#        controller: 'authorization'
#        templateUrl: 'templates/views/authorization.html'
#        
#    $routeProvider.when '/services',
#        templateUrl: 'templates/views/services.html'
#        isRestricted: yes
#    $routeProvider.when '/websites',
#        templateUrl: 'templates/views/websites.html'
#        controller: 'websites'
#        isRestricted: yes
#    $routeProvider.when '/website/:repositoryauthor/:repositoryname',
#        templateUrl: 'templates/views/website.html'
#        controller: 'website'
#        isRestricted: yes
        
    $routeProvider.otherwise
        redirectTo: '/home'