# require

q = require 'q'
fileSystem = require 'q-io/fs'
winston = require 'winston'

utility = require './../../utility'
configuration = require './../../../../configuration/waitress.json'

# private

# public

exports.create = (request, ports) ->
    winston.info 'received a request to create %s nginx entries', request.repository.name
    
    promisesOfTemplates = [
        fileSystem.read configuration.templates.nginx.public
        fileSystem.read configuration.templates.nginx.latest
    ]
    
    promiseOfEntries = q
        .all promisesOfTemplates
        .spread (templatePublic, templateLatest) ->
            # todo
            
    promiseOfSavedEntries = q
        .all promiseOfEntries
        .spread (entryPublic, entryLatest) ->
            # todo
            
    promiseOfNginxChanges = q
        .when promiseOfSavedEntries
        .then utility.runShell 'nginx/restart.sh'
        
    promiseOfResponse = q
        .when promiseOfNginxChanges
        .then () ->
            winston.info 'created nginx entries for website %s', request.repository.name
        .catch (error) ->
            winston.error 'could not create nginx entries: %s', JSON.stringify error, null, 4 