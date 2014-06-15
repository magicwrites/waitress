window.application.run ($rootScope) ->
    $rootScope.getTemplateFrom = (location) ->
        templateLocation = 'templates/' + location + '.html'

    $rootScope.getSvgFrom = (location) ->
        svgLocation = 'images/' + location + '.svg'