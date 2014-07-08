# require

q = require 'q'
fileSystem = require 'q-io/fs'
winston = require 'winston'
path = require 'path'

utility = require './../../utility'
configuration = require './../../../../configuration/waitress.json'

# private

# public

exports.create = (request, ports) ->
    winston.info 'received a request to create %s nginx entries', request.repository.name
    
    
    websiteName =
        request.repository.author +
        configuration.characters.separators.website.replaced + 
        request.repository.name
        
    directories =
        website: configuration.directories.websites + path.sep + websiteName
        available: configuration.directories.nginx.available + path.sep
        enabled: configuration.directories.nginx.enabled + path.sep
        
    files =
        publicFile: directories.available + websiteName + configuration.characters.separators.website.replaced + 'public'
        latestFile: directories.available + websiteName + configuration.characters.separators.website.replaced + 'latest'
        publicLink: directories.enabled + websiteName + configuration.characters.separators.website.replaced + 'public'
        latestLink: directories.enabled + websiteName + configuration.characters.separators.website.replaced + 'latest'
    
    
    promiseOfEntries = q
        .when fileSystem.read configuration.templates.nginx.website
        .then (template) ->
            templatePublic = template.replace '{{ some-directory }}', directories.website + path.sep + 'public'
            templatePublic = templatePublic.replace '{{ some-port }}', ports.public
            
            templateLatest = template.replace '{{ some-directory }}', directories.website + path.sep + 'latest'
            templateLatest = templateLatest.replace '{{ some-port }}', ports.latest
            
            entries =
                public: templatePublic
                latest: templateLatest
            
    promiseOfSavedEntries = q
        .when promiseOfEntries
        .then (entries) ->
            q.all [
                fileSystem.write entries.public, files.publicFile
                fileSystem.write entries.latest, files.latestFile
            ]

    promiseOfSymlinks = q
        .when promiseOfSavedEntries
        .then () ->
            q.all [
                fileSystem.symbolicLink files.publicLink, files.publicFile, 'file'
                fileSystem.symbolicLink files.latestLink, files.latestFile, 'file'
            ]
            
    promiseOfNginxChanges = q
        .when promiseOfSymlinks
        .then utility.runShell 'nginx/restart.sh'
        

    promiseOfResponse = q
        .when promiseOfNginxChanges
        .then () ->
            winston.info 'created nginx entries for website %s', request.repository.name
        .catch (error) ->
            winston.error 'could not create nginx entries: %s', error.message 