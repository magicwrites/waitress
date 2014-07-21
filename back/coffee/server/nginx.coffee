# require

winston = require 'winston'
fileSystem = require 'q-io/fs'
path = require 'path'
q = require 'q'
_ = require 'lodash'

database = require './../database'
utility = require './../utility'

configuration = require './../../../configuration/waitress.json'

# private

getRepositoryDirectoryNameFrom = (repository) ->
    repositoryDirectoryName =
        repository.author +
        configuration.characters.separators.repository.replaced + 
        repository.name
        
getDirectoriesFrom = (request, repositoryDirectoryName) ->
    directories =
        repository: configuration.directories.repositories + path.sep + repositoryDirectoryName
        stored: configuration.directories.repositories + path.sep + repositoryDirectoryName + path.sep + 'stored'
        available: configuration.directories.nginx.available + path.sep
        enabled: configuration.directories.nginx.enabled + path.sep
        
getNginxFilesFrom = (request, repositoryDirectoryName, directories) ->
    files =
        publicFile: directories.available + repositoryDirectoryName + configuration.characters.separators.repository.replaced + 'public'
        latestFile: directories.available + repositoryDirectoryName + configuration.characters.separators.repository.replaced + 'latest'
        publicLink: directories.enabled + repositoryDirectoryName + configuration.characters.separators.repository.replaced + 'public'
        latestLink: directories.enabled + repositoryDirectoryName + configuration.characters.separators.repository.replaced + 'latest'

# public

exports.create = (request) ->
    winston.info 'received a request to create nginx entries for repository %s', request.repository._id
    
    if not request.repository._id then throw utility.getErrorFrom 'request is missing repository identifier'
    
    promiseOfRepository = database.Repository
        .findById request.repository._id
        .exec()
        
    promiseOfPaths = q
        .when promiseOfRepository
        .then (repository) ->
            repositoryDirectoryName = getRepositoryDirectoryNameFrom repository
            directories = getDirectoriesFrom request, repositoryDirectoryName
            files = getNginxFilesFrom request, repositoryDirectoryName, directories
            
            paths =
                directories: directories
                files: files

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

    promiseOfSymlinks = q
        .all [ promiseOfPaths, promiseOfSavedEntries ]
        .spread (paths) ->
            q.all [
                fileSystem.symbolicLink paths.files.publicLink, paths.files.publicFile, 'file'
                fileSystem.symbolicLink paths.files.latestLink, paths.files.latestFile, 'file'
            ]
            
    promiseOfNginxChanges = q
        .when promiseOfSymlinks
        .then utility.runShell 'nginx/restart.sh'

    promiseOfResponse = q
        .all [ promiseOfRepository, promiseOfNginxChanges ]
        .spread (repository) ->
            winston.info 'created nginx entries for repository %s', repository.name
        .catch (error) ->
            winston.error 'could not create nginx entries: %s', error.message