# require

winston = require 'winston'
fileSystem = require 'q-io/fs'
path = require 'path'
q = require 'q'

database = require './../../database'
utility = require './../../utility'

repositoryUtility = require './utility'



exports.buildLatest = (request) ->
    winston.info 'building latest version of the repository'
    
    if not request.repository._id then throw utility.getErrorFrom 'request is missing repository identifier'
    
    promiseOfRepositoryData = database.Repository
        .findById request.repository._id
        .exec()
            
    promiseOfBuilding = q
        .when promiseOfRepositoryData
        .then (repository) ->
            repositoryLatestDirectory = repositoryUtility.getLatestDirectoryFrom repository.author, repository.name
            
            utility.runShell 'repository/build-latest.sh', [ repositoryLatestDirectory ]
            
    promiseOfResponse = q
        .when promiseOfBuilding
        .then () ->
            winston.info 'latest version of the repository %s has been built', request.repository._id
        .catch (error) ->
            winston.error 'latest version of the repository could not be built: %s', error.message



exports.buildPublic = (request) ->
    winston.info 'building public version of the repository'
    
    if not request.repository._id then throw utility.getErrorFrom 'request is missing repository identifier'
    
    promiseOfRepositoryData = database.Repository
        .findById request.repository._id
        .exec()
    
    promiseOfBuilding = q
        .when promiseOfRepositoryData
        .then (repository) ->
            repositoryPublicDirectory = repositoryUtility.getPublicDirectoryFrom repository.author, repository.name
            
            utility.runShell 'repository/build-public.sh', [ repositoryPublicDirectory ]
    
    promiseOfResponse = q
        .when promiseOfBuilding
        .then () ->
            winston.info 'public version of the repository %s has been built', request.repository._id
        .catch (error) ->
            winston.error 'public version of the repository could not be built: %s', error.message



exports.pull = (request) ->
    winston.info 'pulling repository %s', request.repository._id
    
    if not request.repository._id then throw utility.getErrorFrom 'request is missing repository identifier'
    
    promiseOfRepositoryData = database.Repository
        .findById request.repository._id
        .exec()
        
    promiseOfPulling = q
        .when promiseOfRepositoryData
        .then (repository) ->
            repositoryLatestDirectory = repositoryUtility.getLatestDirectoryFrom repository.author, repository.name
            
            utility.runShell 'repository/pull.sh', [ repositoryLatestDirectory ]
            
    promiseOfBuilding = q
        .all [ promiseOfRepositoryData, promiseOfPulling ]
        .spread (repository) ->
            exports.buildLatest request
            
    promiseOfResponse = q
        .all [ promiseOfPulling, promiseOfBuilding ]
        .then () ->
            winston.info 'repository %s latest version has been pulled from its origin', request.repository._id
        .catch (error) ->
            winston.error 'could not pull the latest version of the repository: %s', error.message



exports.publish = (request) ->
    winston.info 'publishing repository %s from latest version', request.repository._id
    
    if not request.repository._id then throw utility.getErrorFrom 'request is missing repository identifier'
    
    promiseOfRepositoryData = database.Repository
        .findById request.repository._id
        .exec()
        
    promiseOfCopying = q
        .when promiseOfRepositoryData
        .then (repository) ->
            repositoryLatestDirectory = repositoryUtility.getLatestDirectoryFrom repository.author, repository.name
            repositoryPublicDirectory = repositoryUtility.getPublicDirectoryFrom repository.author, repository.name
            
            utility.runShell 'repository/publish.sh', [ repositoryLatestDirectory, repositoryPublicDirectory ]
            
    promiseOfBuilding = q
        .all [ promiseOfRepositoryData, promiseOfCopying ]
        .spread (repository) ->
            exports.buildPublic request
    
    promiseOfResponse = q
        .all [ promiseOfBuilding, promiseOfCopying ]
        .then () ->
            winston.info 'repository %s files were copied from latest to public directory', request.repository._id
        .catch (error) ->
            winston.error 'could not copy the repository files: %s', error.message
    
    

exports.getVersions = (request) ->
    winston.info 'retrieving versions for repository %s of %s', request.repository.name, request.repository.author
        
    if not request.repository.author then throw utility.getErrorFrom 'request is missing repository author'
    if not request.repository.name   then throw utility.getErrorFrom 'request is missing repository name'
    
    repositoryLatestDirectory = repositoryUtility.getLatestDirectoryFrom request.repository.author, request.repository.name
    repositoryPublicDirectory = repositoryUtility.getPublicDirectoryFrom request.repository.author, request.repository.name
    
    promiseOfPublicPackageExistence = fileSystem.exists repositoryPublicDirectory + path.sep + 'package.json'
    
    promisesOfPackages = q
        .when promiseOfPublicPackageExistence
        .then (isPublicPackageJsonPresent) ->
            promisesOfPackages = [ fileSystem.read repositoryLatestDirectory + path.sep + 'package.json' ]
            
            if  isPublicPackageJsonPresent
                promiseOfPublicPackage = fileSystem.read repositoryPublicDirectory + path.sep + 'package.json'
                promisesOfPackages.push promiseOfPublicPackage
            else
                promisesOfPackages.push '{}' # simulate file exists
                
            return promisesOfPackages

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



exports.checkPackageJsonPresence = (request) ->
    winston.info 'resolving package.json presence for repository %s', request.repository.name
        
    if not request.repository.author then throw utility.getErrorFrom 'request is missing repository author'
    if not request.repository.name   then throw utility.getErrorFrom 'request is missing repository name'
    
    repositoryLatestDirectory = repositoryUtility.getLatestDirectoryFrom request.repository.author, request.repository.name
    
    promiseOfResponse = q
        .when fileSystem.exists repositoryLatestDirectory + path.sep + 'package.json'
        .then (isPresent) ->
            winston.info 'package.json presence resulted in %s', isPresent
            
            return isPresent
        .catch (error) ->
            winston.error 'could not resolve package.json presence: %s', error.message



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