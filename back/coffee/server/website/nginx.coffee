# require

q = require 'q'
fileSystem = require 'q-io/fs'
winston = require 'winston'
path = require 'path'

utility = require './../../utility'
websiteUtility = require './utility'
configuration = require './../../../../configuration/waitress.json'

# private

# public

exports.remove = (request) ->
    winston.info 'received a request to remove %s nginx entries', request.repository.name
    
    websiteName = websiteUtility.getWebsiteNameFrom request
    directories = websiteUtility.getDirectoriesFrom request, websiteName
    files = websiteUtility.getNginxFilesFrom request, websiteName, directories
    
    promisesOfRemoval = [
        fileSystem.remove files.publicFile
        fileSystem.remove files.latestFile
        fileSystem.remove files.publicLink
        fileSystem.remove files.latestLink
    ]

    promiseOfNginxChanges = q
        .when promisesOfRemoval
        .then utility.runShell 'nginx/restart.sh'
    
    promiseOfResponse = q
        .when promiseOfNginxChanges
        .then () ->
            winston.info 'removed nginx entries for website %s', request.repository.name
        .catch (error) ->
            winston.error 'could not remove nginx entries: %s', error.message 



exports.create = (request, ports) ->
    winston.info 'received a request to create %s nginx entries', request.repository.name
    
    websiteName = websiteUtility.getWebsiteNameFrom request
    directories = getDirectoriesFrom request, websiteName
    files = getFilesFrom request, websiteName, directories
    
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
                fileSystem.write files.publicFile, entries.public
                fileSystem.write files.latestFile, entries.latest
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