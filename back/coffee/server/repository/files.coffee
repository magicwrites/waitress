# require

winston = require 'winston'
fileSystem = require 'q-io/fs'
path = require 'path'
q = require 'q'

database = require './../../database'
utility = require './../../utility'

repositoryUtility = require './utility'

# public

exports.getVersions = (request) ->
    winston.info 'retrieving versions for repository %s of %s', request.repository.name, request.repository.author
        
    if not request.repository.author then throw utility.getErrorFrom 'request is missing repository author'
    if not request.repository.name   then throw utility.getErrorFrom 'request is missing repository name'
    
    repositoryLatestDirectory = repositoryUtility.getLatestDirectoryFrom request.repository.author, request.repository.name
    repositoryPublicDirectory = repositoryUtility.getPublicDirectoryFrom request.repository.author, request.repository.name
    
    promisesOfPackages = [
        fileSystem.read repositoryLatestDirectory + path.sep + 'package.json'
        fileSystem.read repositoryPublicDirectory + path.sep + 'package.json'
    ]

    promiseOfVersions = q
        .all promisesOfPackages
        .spread (latestPackageJsonString, publicPackageJsonString) ->
            latestPackage = JSON.parse latestPackageJsonString
            publicPackage = JSON.parse publicPackageJsonString
            
            versions =
                latest: latestPackage.version
                public: publicPackage.version
    
    promiseOfResponse = q
        .when promiseOfVersions
        .then (versions) ->
            winston.info 'repository versions retrieved as latest %s and public %s', versions.latest, versions.public
            
            return versions
        .catch (error) ->
            winston.warn 'could not retrieve versions: %s', error.message



exports.checkGruntfilePresence = (request) ->
    winston.info 'resolving gruntfile presence for repository %s', request.repository.name
        
    if not request.repository.author then throw utility.getErrorFrom 'request is missing repository author'
    if not request.repository.name   then throw utility.getErrorFrom 'request is missing repository name'
    
    repositoryLatestDirectory = repositoryUtility.getLatestDirectoryFrom request.repository.author, request.repository.name
    
    promisesOfGruntfileExistence = [
        fileSystem.exists repositoryLatestDirectory + path.sep + 'Gruntfile.coffee'
        fileSystem.exists repositoryLatestDirectory + path.sep + 'Gruntfile.js'
    ]
    
    promiseOfResponse = q
        .all promisesOfGruntfileExistence
        .spread (coffee, javascript) ->
            isPresent = if coffee or javascript then yes else no
                
            winston.info 'gruntfile presence resulted in %s', isPresent
            
            return isPresent
        .catch (error) ->
            winston.error 'could not resolve gruntfile presence: %s', error.message



exports.cloneSourceIntoLatestDirectory = (request) ->
    winston.info 'cloning repository %s of %s into latest directory', request.repository.name, request.repository.author
    
    if not request.repository.author then throw utility.getErrorFrom 'request is missing repository author'
    if not request.repository.name   then throw utility.getErrorFrom 'request is missing repository name'
    
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
    
    if not request.repository._id then throw utility.getErrorFrom 'request is missing repository identifier'
    
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