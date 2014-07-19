# require

winston = require 'winston'
fileSystem = require 'q-io/fs'
path = require 'path'
q = require 'q'

database = require './../../database'
utility = require './../../utility'

repositoryUtility = require './utility'

# public

exports.cloneSourceIntoLatestDirectory = (request) ->
    winston.info 'cloning repository %s of %s into latest directory', request.repository.name, request.repository.author
    
    promiseOfGithubCredentials = database.Github
        .findOne()
        .exec()
    
    promiseOfCloning = q
        .when promiseOfGithubCredentials
        .then (github) ->
            repositoryDirectory = repositoryUtility.getDirectoryFrom request.repository.author, request.repository.name
            
            utility.runShell 'repository/create.sh', [
                repositoryDirectory
                request.repository.author
                request.repository.name
                github.username
                github.password
            ]

    promiseOfResponse = q
        .when promiseOfCloning
        .then () ->
            winston.info 'repository %s of %s was cloned into latest directory', request.repository.name, request.repository.name
        .catch (error) ->
            winston.error 'could not clone the repository: %s', error.message
            
            
            
exports.removeFromHardDrive = (request) ->
    winston.info 'removing repository %s data from hard drive', request.repository._id
    
    promiseOfRepositoryData = database.Repository
        .findById request.repository._id
        .exec()
    
    promiseOfRemovalFromHardDrive = q
        .when promiseOfRepositoryData
        .then (repository) ->
            repositoryDirectory = repositoryUtility.getDirectoryFrom repository.author, repository.name
            
            fileSystem.removeTree repositoryDirectory
            
    promiseOfResponse = q
        .when promiseOfRemovalFromHardDrive
        .then () ->
            winston.info 'repository %s was removed from hard drive', request.repository._id
        .catch (error) ->
            winston.error 'could not remove the repository from hard drive: %s', error.message