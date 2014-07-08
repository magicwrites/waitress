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
    
    
    
exports.create = (request, ports) ->
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
        .catch (error) ->
            winston.warn 'there was an error during github repository setup: %s', error.message
        
    promiseOfListener = q
        .when promiseOfCredentials
        .then (credentials) ->
            utility.runShell 'github/listener.sh', [
                ports.github
                request.repository.author
                request.repository.name
                credentials.username
                credentials.password
            ]
        .catch (error) ->
            console.log error
            winston.warn 'there was an error during github listener setup: %s', error.message
    
    promiseOfResponse = q
        .all [
            promiseOfRepository
            promiseOfListener
        ]
        .then () ->
            winston.info 'github has been created for a website %s', request.repository.name
        .catch (error) ->
            winston.error 'github could not be created: %s', error.message 