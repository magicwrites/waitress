# require

q = require 'q'
fileSystem = require 'q-io/fs'
winston = require 'winston'
path = require 'path'

configuration = require './../../../../configuration/waitress.json'

# private

# public

exports.create = (request) ->
    winston.info 'received a request to create %s repository file structure', request.repository.name
    
    repositoryDirectory =
        request.repository.author +
        configuration.characters.separators.website.replaced +
        request.repository.name
        
    emptyJsonArray = JSON.stringify [], null, 4
    
    websiteDirectory = configuration.directories.websites + path.sep + repositoryDirectory + path.sep
    
    promises = [
        fileSystem.makeTree websiteDirectory + 'latest'
        fileSystem.makeTree websiteDirectory + 'public'
        fileSystem.makeTree websiteDirectory + 'stored'
        fileSystem.write emptyJsonArray, websiteDirectory + 'stored.json'
    ]
    
    q
        .all promises
        .then () ->
            winston.info '%s website directory structure is created', request.repository.name
        .catch (error) ->
            winston.error 'could not create website directory structure: %s', error.message