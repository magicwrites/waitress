# require

q = require 'q'
fileSystem = require 'q-io/fs'
path = require 'path'
winston = require 'winston'

utility = require './../../utility'
configuration = require './../../../../configuration/waitress.json'

# public

exports.pull = (request) ->
    winston.info 'github pull request received for %s %s website', request.repository.author, request.repository.name

    
    
exports.remove = (request) ->
    #
    
    
    
exports.create = (request) ->
    winston.info 'github create request received for %s %s website', request.repository.author, request.repository.name
    
    promiseOfCredentials = q
        .when fileSystem.read configuration.files.github.json
        .then (githubFileContents) ->
            JSON.parse githubFileContents
    
    promiseOfRepository = q
        .when promiseOfCredentials
        .then (credentials) ->
            websiteDirectory =
                configuration.directories.websites +
                path.sep +
                request.repository.author +
                configuration.characters.separators.website.replaced + 
                request.repository.name
                
            utility.runShell 'github/create.sh', [
                websiteDirectory
                request.repository.author
                request.repository.name
                credentials.username
                credentials.password
            ]
        
    promiseOfListener = q
        .when promiseOfRepository
        .then () ->
            # todo: activate listener
    
    promiseOfResponse = q
        .all [
            promiseOfRepository
            promiseOfListener
        ]
        .then () ->
            winston.info 'github has been created for a website %s', request.repository.name
        .catch (error) ->
            winston.error 'github could not be created: %s', error.message 