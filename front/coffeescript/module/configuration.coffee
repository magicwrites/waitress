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
        
    $routeProvider.when '/repositories',
        templateUrl: 'templates/views/repositories.html'
        controller: 'repositories'
        isRestricted: yes
    $routeProvider.when '/repositories/new',
        templateUrl: 'templates/views/repositories/new.html'
        controller: 'repositoriesNew'
        isRestricted: yes
    $routeProvider.when '/repositories/details/:id',
        templateUrl: 'templates/views/repositories/details.html'
        controller: 'repositoriesDetails'
        isRestricted: yes
        
    $routeProvider.when '/logs',
        templateUrl: 'templates/views/logs.html'
        controller: 'logs'
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