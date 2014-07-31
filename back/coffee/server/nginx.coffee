winston    = require 'winston'
fileSystem = require 'q-io/fs'
path       = require 'path'
q          = require 'q'
_          = require 'lodash'

configuration = require './../../../configuration/waitress.json'
database      = require './../database'
utility       = require './../utility'



getRepositoryDirectoryNameFrom = (repository) ->
    repositoryDirectoryName =
        repository.author +
        configuration.characters.separators.repository.replaced + 
        repository.name
        
getDirectoriesFrom = (request, repositoryDirectoryName) ->
    directories =
        repository: configuration.directories.repositories + path.sep + repositoryDirectoryName
        stored: configuration.directories.repositories + path.sep + repositoryDirectoryName + path.sep + 'stored'
        configurations: configuration.directories.nginx.configurations + path.sep
        
getNginxFilesFrom = (request, repositoryDirectoryName, directories) ->
    files =
        publicFile: directories.configurations + repositoryDirectoryName + configuration.characters.separators.repository.replaced + 'public.conf'
        latestFile: directories.configurations + repositoryDirectoryName + configuration.characters.separators.repository.replaced + 'latest.conf'
        
getPaths = (request, repository) ->
    repositoryDirectoryName = getRepositoryDirectoryNameFrom repository
    directories = getDirectoriesFrom request, repositoryDirectoryName
    files = getNginxFilesFrom request, repositoryDirectoryName, directories

    paths =
        directories: directories
        files: files



exports.getPaths = (request) ->
    winston.info 'received a request to calculate paths for repository %s', request.repository._id
    
    if not request.repository._id then throw utility.getErrorFrom 'request is missing repository identifier'
    
    promiseOfRepository = database.Repository
        .findById request.repository._id
        .exec()
        
    promiseOfPaths = q
        .when promiseOfRepository
        .then (repository) ->
            paths = getPaths request, repository

    promiseOfResponse = q
        .when promiseOfPaths
        .then (paths) ->
            winston.info 'paths calculated successfuly for repository %s', request.repository._id
            
            return paths
        .catch (error) ->
            winston.error 'could not calculate paths: %s', error.message



exports.remove = (request) ->
    winston.info 'received a request to remove nginx entries for repository %s', request.repository._id
    
    if not request.repository._id then throw utility.getErrorFrom 'request is missing repository identifier'
    
    promiseOfRepository = database.Repository
        .findById request.repository._id
        .exec()
        
    promiseOfPaths = q
        .when promiseOfRepository
        .then (repository) ->
            paths = getPaths request, repository
        
    promiseOfNginxEntriesRemoval = q
        .when promiseOfPaths
        .then (paths) ->
            promisesOfRemoval = [
                fileSystem.remove paths.files.publicFile
                fileSystem.remove paths.files.latestFile
            ]

            promiseOfRemovals = q.all promisesOfRemoval
    
    promiseOfNginxChanges = q
        .when promiseOfNginxEntriesRemoval
        .then () ->
            utility.runShell 'nginx/restart.sh'

    promiseOfResponse = q
        .all [ promiseOfRepository, promiseOfNginxChanges ]
        .spread (repository) ->
            winston.info 'removed nginx entries for repository %s', repository.name
        .catch (error) ->
            winston.error 'could not remove nginx entries: %s', error.message



exports.create = (request) ->
    winston.info 'received a request to create nginx entries for repository %s', request.repository._id
    
    if not request.repository._id then throw utility.getErrorFrom 'request is missing repository identifier'
    
    promiseOfRepository = database.Repository
        .findById request.repository._id
        .exec()
        
    promiseOfPaths = q
        .when promiseOfRepository
        .then (repository) ->
            paths = getPaths request, repository

    promiseOfTemplate = fileSystem.read configuration.templates.nginx.repository
    
    promiseOfEntries = q
        .all [ promiseOfTemplate, promiseOfPaths ]
        .spread (template, paths) ->
            templatePublic = template.replace '{{ some-directory }}', paths.directories.repository + path.sep + 'public'
            templatePublic = templatePublic.replace '{{ some-port }}', request.reservations.public.port
            
            templateLatest = template.replace '{{ some-directory }}', paths.directories.repository + path.sep + 'latest'
            templateLatest = templateLatest.replace '{{ some-port }}', request.reservations.latest.port
            
            entries =
                public: templatePublic
                latest: templateLatest

    promiseOfSavedEntries = q
        .all [ promiseOfEntries, promiseOfPaths ]
        .spread (entries, paths) ->
            q.all [
                fileSystem.write paths.files.publicFile, entries.public
                fileSystem.write paths.files.latestFile, entries.latest
            ]

    promiseOfNginxChanges = q
        .when promiseOfSavedEntries
        .then () ->
            utility.runShell 'nginx/restart.sh'

    promiseOfResponse = q
        .all [ promiseOfRepository, promiseOfNginxChanges ]
        .spread (repository) ->
            winston.info 'created nginx entries for repository %s', repository.name
        .catch (error) ->
            winston.error 'could not create nginx entries: %s', error.message