# require

winston = require 'winston'
childProcess = require 'child-process-promise'
q = require 'q'

user = require './../user.coffee'

# public

exports.create = (request) ->
    deferred = q.defer()
    
    scriptParameters = [
        'back/shell/website/create.sh',
        request.repository.author,
        request.repository.name,
        request.user.username,
        request.user.password
    ]
    
    childProcess.spawn 'bash', scriptParameters
        .then () ->
            website =
                repository: request.repository
                public: null
                latest: '0.0.1'

            deferred.resolve website
        .catch (error) ->
            deferred.reject error
            winston.error 'waitress has failed to create a new website - %s/%s', request.repository.author, request.repository.name
    
    deferred.promise

exports.remove = (request) ->
    winston.info 'waitress has received a website removal request'
    
    socket = this
    repository = request.repository
    
    scriptParameters = [
        'back/shell/website/remove.sh',
        repository.author,
        repository.name
    ]

    user.isAuthorizedProperly request
        .then childProcess.spawn 'bash', scriptParameters
        .then () ->
            winston.info 'waitress has removed a website - ' + request.repository
            socket.emit 'waitress website remove', request.repository
        .fail (error) ->
            winston.error 'waitress has failed to remove a website', request.repository