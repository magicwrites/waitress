# require

winston = require 'winston'
fileSystem = require 'q-io/fs'
q = require 'q'

database = require './../database'
utility = require './../utility'
user = require './user'

#repositoryPorts = require './repository/ports'
#repositoryNginx = require './repository/nginx'
repositoryFiles = require './repository/files'
#repositoryGithub = require './repository/github'
#repositoryVersions = require './repository/versions'

# public

exports.get = (request) ->
    winston.info 'received a request to retrieve repository details'
    
    promiseOfRepository = database.Repository
        .findById request.repository._id
        .exec()
        
    promiseOfResponse = q
        .when promiseOfRepository
        .then (repository) ->
            winston.info 'repository details retrieved successfuly'
            
            return repository
        .catch (error) ->
            winston.error 'could not retrieve repository details: %s', error.message



exports.list = (request) ->
    winston.info 'received a repository listing request'
    
    promiseOfRepositories = database.Repository
        .find()
        .exec()
        
    promiseOfResponse = q
        .when promiseOfRepositories
        .then (repositories) ->
            winston.info 'repository listing completed successfuly, found %s repositories', repositories.length
            
            return repositories
        .catch (error) ->
            winston.error 'could not list repositories: %s', error.message



exports.create = (request) ->
    winston.info 'received a repository creation request'
    
    promiseOfGruntfilePresence = q
        .when repositoryFiles.cloneSourceIntoLatestDirectory request
        .then () ->
            repositoryFiles.checkGruntfilePresence request

    promiseOfRepositoryInDatabase = q
        .when promiseOfGruntfilePresence 
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
    
    promiseOfRemovalFromDatabase = q
        .when repositoryFiles.removeFromHardDrive request
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