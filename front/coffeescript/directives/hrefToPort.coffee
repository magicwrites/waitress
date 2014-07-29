window.application.directive 'waitressHrefToPort', ($location) ->
    exposed =
        restrict: 'A'
        replace: false
        link: ($scope, element, attributes) ->
            port = attributes.waitressHrefToPort
            href = $location.$$protocol + '://' + $location.$$host + ':' + port
            
            element.attr 'href', href