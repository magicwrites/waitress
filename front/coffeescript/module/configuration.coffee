window.application.config ($routeProvider) ->
    $routeProvider.when '/home',
        templateUrl: 'templates/views/home.html'
        controller: 'home'
        
    $routeProvider.when '/user',
        templateUrl: 'templates/views/user.html'
        controller: 'user'
        isRestricted: yes
    $routeProvider.when '/user/create',
        templateUrl: 'templates/views/user/create.html'
        controller: 'userCreate'
    $routeProvider.when '/user/authorize',
        templateUrl: 'templates/views/user/authorize.html'
        controller: 'userAuthorize'
    $routeProvider.when '/user/github/set',
        templateUrl: 'templates/views/user/github/set.html'
        controller: 'userGithubSet'
        isRestricted: yes
        
    $routeProvider.when '/websites',
        templateUrl: 'templates/views/websites.html'
        controller: 'websites'
        isRestricted: yes
    $routeProvider.when '/websites/new',
        templateUrl: 'templates/views/websites/new.html'
        controller: 'websitesNew'
        isRestricted: yes
    $routeProvider.when '/websites/details/:id',
        templateUrl: 'templates/views/websites/details.html'
        controller: 'websitesDetails'
        isRestricted: yes
        
#    $routeProvider.when '/roadmap',
#        templateUrl: 'templates/views/roadmap.html'
#    $routeProvider.when '/authorization',
#        controller: 'authorization'
#        templateUrl: 'templates/views/authorization.html'
#        
#    $routeProvider.when '/services',
#        templateUrl: 'templates/views/services.html'
#        isRestricted: yes
#    $routeProvider.when '/website/:repositoryauthor/:repositoryname',
#        templateUrl: 'templates/views/website.html'
#        controller: 'website'
#        isRestricted: yes
        
    $routeProvider.otherwise
        redirectTo: '/home'