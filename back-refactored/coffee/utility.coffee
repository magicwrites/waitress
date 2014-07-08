# require

q = require 'q'
winston = require 'winston'
moment = require 'moment'

configuration = require './../../configuration/waitress.json'

# private

getNiceTimestamp = () ->
    '[ ' + new moment().format 'YYYY-MM-DD HH:mm:ss' + ' ]'

constants =
    configurations:
        winston:
            console:
                colorize: yes
                timestamp: getNiceTimestamp
            file:
                colorize: yes
                timestamp: getNiceTimestamp
                filename: './' + configuration.files.logs.json
    events:
        delimiter: ':'

# public

exports.wrapInPromise = (something) ->
    deferred = q.defer()
    deferred.resolve something
    deferred.promise

    
        
exports.setLoggingFor = (winston) ->
    winston.remove winston.transports.Console
    winston.add winston.transports.Console, constants.configurations.winston.console
    winston.add winston.transports.File, constants.configurations.winston.file
        
        
        
exports.runShell = (path, providedParameters = []) ->
    scriptParameters = [
        'back/shell/' + path
    ]

    scriptParameters = _.union scriptParameters, providedParameters

    childProcess.spawn 'bash', scriptParameters
    
    
    
exports.handle = (socket, eventName, handler, authorizer) ->
    authorizer = authorizer || exports.wrapInPromise yes
    
    socket.on eventName, (request) ->
        winston.info 'received %s event', eventName
        
        # rewrite to be more readable if in need to work with this function again
        
        q
            .when authorizer request
            .then (isAuthorized) ->
                if isAuthorized
                    q
                        .when handler request
                        .then (response) ->
                            winston.info 'event %s was handled successfuly', eventName

                            result =
                                error: null
                                response: response

                            socket.emit eventName, result
                else
                    winston.warn '%s event was not properly authorized', eventName
                    
                    result =
                        error: 'unauthorized'
                        response: null
                        
                    socket.emit eventName, result
                    
            .catch (error) ->
                winston.error 'event %s could not be handled successfuly: %s', eventName, JSON.stringify error, null, 4

                result =
                    error: error
                    response: null

                socket.emit eventName, result