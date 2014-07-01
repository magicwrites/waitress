# require

winston = require 'winston'
childProcess = require 'child-process-promise'
user = require './user.coffee'
fileSystem = require 'q-io/fs'
q = require 'q'

websiteReader = require './website/reader.coffee'
websiteShell = require './website/shell.coffee'
websiteNginx = require './website/nginx.coffee'
websiteGithub = require './website/github.coffee'
websitePackage = require './website/package.coffee'
    
# public

# expose api to publish a website, which:
# copies the entire latest directory to the public one

exports.publish = () ->
    # do it!
    
exports.list = websiteReader.list
exports.get = websiteReader.get

#exports.create = websiteShell.create
exports.remove = websiteShell.remove

exports.create = (request) ->
    winston.info 'waitress has received a website creation request'
    
    socket = this
    author = request.repository.author
    name = request.repository.name
    
    promisesOfCreation = [
        websiteShell.create request
        websiteNginx.create request
        websiteGithub.createListener request
    ]
    
    q
        .when user.isAuthorizedProperly request
        .then () ->
            q
                .all promisesOfCreation
                .then () ->
                    website =
                        repository: request.repository
                        public: websitePackage.getVersion author, name, 'public'
                        latest: websitePackage.getVersion author, name, 'latest'

                    winston.info 'waitress has created a new website - %s/%s', author, name
                    socket.emit 'waitress website create', website
                    
                    websiteShell.setup request
                .catch (error) ->
                    console.log error
                    winston.error 'waitress has failed to create a new website - %s/%s', author, name