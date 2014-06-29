# require

winston = require 'winston'
childProcess = require 'child-process-promise'
q = require 'q'

user = require './../user.coffee'

# private

logPrefix = 'website shell: '

# public

exports.setup = (request) ->
    winston.info logPrefix + 'setting up latest %s/%s website', request.repository.author, request.repository.name
    
    scriptParameters = [
        'back/shell/website/setup.sh',
        request.repository.author,
        request.repository.name
    ]

    user.isAuthorizedProperly request
        .then childProcess.spawn 'bash', scriptParameters
        .then () ->
            winston.info logPrefix + 'website %s/%s has been set up', request.repository.author, request.repository.name
        .catch (error) ->
            winston.warn logPrefix + 'could not setup website %s/%s', request.repository.author, request.repository.name

exports.create = (request) ->
    scriptParameters = [
        'back/shell/website/create.sh',
        request.repository.author,
        request.repository.name,
        request.user.username,
        request.user.password
    ]
    
    q
        .when childProcess.spawn 'bash', scriptParameters
        .then () ->
            website =
                repository: request.repository
                public: null
                latest: '0.0.1'

            website
        .catch (error) ->
            winston.error logPrefix + 'waitress has failed to create a new website - %s/%s', request.repository.author, request.repository.name

exports.remove = (request) ->
    winston.info logPrefix + 'waitress has received a website removal request'
    
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
            winston.info logPrefix + 'waitress has removed a website - ' + request.repository
            socket.emit 'waitress website remove', request.repository
        .fail (error) ->
            winston.error logPrefix + 'waitress has failed to remove a website', request.repository