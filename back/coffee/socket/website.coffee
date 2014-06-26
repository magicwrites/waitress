# require

winston = require 'winston'
childProcess = require 'child-process-promise'
user = require './user.coffee'
q = require 'q'

# private

extractFrom = (repositoryString) ->
    parts = repositoryString.split '/'
    
    repository =
        author: parts[0]
        name: parts[1]
    
# public

# expose api to publish a website, which:
# copies the entire latest directory to the public one

exports.publish = () ->
    # do it!
    
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
    
    user.isAuthorizedProperly data.user
        .then childProcess.spawn 'bash', scriptParameters
        .then () ->
            website =
                repository: data.repository
                public: null
                latest: '0.0.1'

            winston.info 'waitress has created a new website - ' + data.repository
            socket.emit 'waitress website create', website