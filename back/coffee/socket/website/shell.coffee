# require

winston = require 'winston'
childProcess = require 'child-process-promise'

user = require './../user.coffee'

# private

extractFrom = (repositoryString) ->
    parts = repositoryString.split '/'
    
    repository =
        author: parts[0]
        name: parts[1]

# public

exports.create = (data) ->
    winston.info 'waitress has received a website creation request'
    
    socket = this
    repository = extractFrom data.repository
    
    scriptParameters = [
        'back/shell/website/create.sh',
        repository.author,
        repository.name,
        data.user.username,
        data.user.password
    ]
    
    user.isAuthorizedProperly data
        .then childProcess.spawn 'bash', scriptParameters
        .then () ->
            website =
                repository: data.repository
                public: null
                latest: '0.0.1'

            winston.info 'waitress has created a new website - ' + data.repository
            socket.emit 'waitress website create', website
        .fail (error) ->
            winston.error 'waitress has failed to create a new website - %s', data.repository

exports.remove = (data) ->
    winston.info 'waitress has received a website removal request'
    
    socket = this
    repository = data.repository
    
    scriptParameters = [
        'back/shell/website/remove.sh',
        repository.author,
        repository.name
    ]

    user.isAuthorizedProperly data
        .then childProcess.spawn 'bash', scriptParameters
        .then () ->
            winston.info 'waitress has removed a website - ' + data.repository
            socket.emit 'waitress website remove', data.repository
        .fail (error) ->
            winston.error 'waitress has failed to remove a website - %s', data.repository