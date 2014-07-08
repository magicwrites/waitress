# require

q = require 'q'
fileSystem = require 'q-io/fs'
winston = require 'winston'

# private

# public

exports.create = (request) ->
    winston.info 'received a request to create %s repository file structure', request.repository.name
    
    repositoryDirectory =
        request.repository.author +
        configuration.characters.separators.website.replaced +
        request.repository.name
        
    emptyJsonArray = JSON.stringify [], null, 4
    
    promises = [
        fileSystem.makeTree configuration.directories.websites + '/' + repositoryDirectory + '/latest'
        fileSystem.makeTree configuration.directories.websites + '/' + repositoryDirectory + '/public'
        fileSystem.makeTree configuration.directories.websites + '/' + repositoryDirectory + '/stored'
        fileSystem.write configuration.directories.websites + '/' + repositoryDirectory + '/stored.json', emptyJsonArray
    ]
    
    q
        .all promises
        .then () ->
            winston.info '%s website directory structure is created', request.repository.name
        .catch (error) ->
            winston.error 'could not create website directory structure: %s', JSON.stringify error, null, 4