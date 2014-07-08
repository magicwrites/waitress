# require

q = require 'q'
fileSystem = require 'q-io/fs'
winston = require 'winston'
path = require 'path'

configuration = require './../../../../configuration/waitress.json'

# private

getWebsiteDirectoryFrom = (request) ->
    repositoryDirectoryName =
        request.repository.author +
        configuration.characters.separators.website.replaced +
        request.repository.name
    
    websiteDirectory = configuration.directories.websites + path.sep + repositoryDirectoryName

# public

exports.remove = (request) ->
    winston.info 'received a request to remove %s repository file structure', request.repository.name
    
    websiteDirectory = getWebsiteDirectoryFrom request
    
    promiseOfResponse = q
        .when fileSystem.removeTree websiteDirectory
        .then () ->
            winston.info '%s website directory structure has been removed', request.repository.name
        .catch (error) ->
            winston.error 'could not remove website directory structure: %s', error.message
    

exports.create = (request) ->
    winston.info 'received a request to create %s repository file structure', request.repository.name
        
    emptyJsonArray = JSON.stringify [], null, 4
    websiteDirectory = getWebsiteDirectoryFrom request
    
    promises = [
        fileSystem.makeTree websiteDirectory + path.sep + 'latest'
        fileSystem.makeTree websiteDirectory + path.sep + 'public'
        fileSystem.makeTree websiteDirectory + path.sep + 'stored'
        fileSystem.write emptyJsonArray, websiteDirectory + path.sep + 'stored.json'
    ]
    
    promiseOfResponse = q
        .all promises
        .then () ->
            winston.info '%s website directory structure is created', request.repository.name
        .catch (error) ->
            winston.error 'could not create website directory structure: %s', error.message