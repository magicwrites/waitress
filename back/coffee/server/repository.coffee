# require

winston = require 'winston'
fileSystem = require 'q-io/fs'
path = require 'path'
q = require 'q'

configuration = require './../../../configuration/waitress.json'
database = require './../database'
utility = require './../utility'
user = require './user'
#repositoryPorts = require './repository/ports'
#repositoryNginx = require './repository/nginx'
#repositoryFiles = require './repository/files'
#repositoryGithub = require './repository/github'
#repositoryVersions = require './repository/versions'

# private

getRepositoryDirectoryFrom = (author, name) ->
    repositoryDirectory =
        configuration.directories.websites +
        path.sep +
        author +
        configuration.characters.separators.website.replaced +
        name

# public

exports.get = (request) ->
    winston.info 'received a repository get information request'
    
    # todo



exports.list = (request) ->
    winston.info 'received a repository listing request'
    
    promiseOfWebsites = database.Repository
        .find()
        .exec()
        
    promiseOfResponse = q
        .when promiseOfWebsites
        .then (repositories) ->
            winston.info 'repository listing completed successfuly, found %s repositories', repositories.length
            
            return repositories
        .catch (error) ->
            winston.error 'could not list repositories: %s', error.message



exports.create = (request) ->
    winston.info 'received a repository creation request'
    
    promiseOfGithubCredentials = database.Github
        .findOne()
        .exec()
    
    promiseOfClonedRepository = q
        .when promiseOfGithubCredentials
        .then (github) ->
            repositoryDirectory = getRepositoryDirectoryFrom request.repository.author, request.repository.name
            
            utility.runShell 'repository/create.sh', [
                repositoryDirectory
                request.repository.author
                request.repository.name
                github.username
                github.password
            ]

    promiseOfRepositoryInDatabase = q
        .when promiseOfClonedRepository
        .then () ->
            database.Repository.create request.repository
    
    promiseOfResponse = q
        .when promiseOfRepositoryInDatabase
        .then (repository) ->
            winston.info 'repository %s was successfuly created', request.repository.name
            
            return repository
        .catch (error) ->
            winston.error 'could not create repository: %s', error.message



exports.remove = (request) ->
    winston.info 'received a repository removal request for repository %s', request.repository._id
    
    promiseOfRepositoryData = database.Repository
        .findById request.repository._id
        .exec()
    
    promiseOfRemovalFromHardDrive = q
        .when promiseOfRepositoryData
        .then (repository) ->
            repositoryDirectory = getRepositoryDirectoryFrom repository.author, repository.name
            
            fileSystem.removeTree repositoryDirectory
    
    promiseOfRemovalFromDatabase = q
        .when promiseOfRemovalFromHardDrive
        .then () ->
            database.Repository
                .remove
                    _id: request.repository._id
                .exec()
    
    promiseOfResponse = q
        .when promiseOfRemovalFromDatabase
        .then () ->
            winston.info 'repository %s was successfuly removed', request.repository._id
        .catch (error) ->
            winston.error 'could not remove repository: %s', error.message