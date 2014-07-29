winston = require 'winston'
fileSystem = require 'q-io/fs'
q = require 'q'

database = require './../database'
utility = require './../utility'
user = require './user'
nginx = require './nginx'
reservation = require './reservation'

repositoryFiles = require './repository/files'



exports.pull = (request) ->
    winston.info 'received a request to pull latest version of a %s repository', request.repository._id
    
    if not request.repository._id then throw utility.getErrorFrom 'request is missing repository identifier'
    
    promiseOfPulling = repositoryFiles.pull request
    
    promiseOfPullDateUpdate = database.Repository
        .findByIdAndUpdate request.repository._id, { dateOfLatestPulling: new Date() }
        .exec()
        
    promisesOfPulling = [
        promiseOfPulling
        promiseOfPullDateUpdate
    ]
    
    promiseOfResponse = q
        .all promisesOfPulling
        .then () ->
            winston.info 'repository %s was successfuly pulled', request.repository._id
        .catch (error) ->
            winston.error 'could not pull repository: %s', error.message



exports.publish = (request) ->
    winston.info 'received a request to publish a %s repository from latest version', request.repository._id
    
    if not request.repository._id then throw utility.getErrorFrom 'request is missing repository identifier'
    
    promiseOfPublishing = repositoryFiles.publish request
    
    promiseOfPublishingDateUpdate = database.Repository
        .findByIdAndUpdate request.repository._id, { dateOfLatestPublishing: new Date() }
        .exec()
        
    promisesOfPublishing = [
        promiseOfPublishing
        promiseOfPublishingDateUpdate
    ]
    
    promiseOfResponse = q
        .all promisesOfPublishing
        .then () ->
            winston.info 'repository %s was successfuly published', request.repository._id
        .catch (error) ->
            winston.error 'could not publish repository: %s', error.message
            
    
    
exports.hide = (request) ->
    winston.info 'received a request to hide a repository nginx exposure'
    
    if not request.repository._id then throw utility.getErrorFrom 'request is missing repository identifier'
    
    promiseOfReservationsRemoval = database.Reservation
        .remove
            repository: request.repository._id
        .exec()
    
    promiseOfNginxHiding = q
        .when promiseOfReservationsRemoval
        .then () ->
            nginx.remove request
            
    promiseOfResponse = q
        .all [ promiseOfReservationsRemoval, promiseOfNginxHiding ]
        .then () ->
            winston.info 'repository %s was successfuly removed from nginx exposure', request.repository._id
        .catch (error) ->
            winston.error 'could not hide repository: %s', error.message

            

exports.expose = (request) ->
    winston.info 'received a request to expose a repository through nginx'
    
    promiseOfReservations = reservation.create request
    
    promiseOfNginxExposure = q
        .when promiseOfReservations
        .then (reservations) ->
            request.reservations = reservations
            nginx.create request
            
    promiseOfPublicBuild = repositoryFiles.buildPublic request
    promiseOfLatestBuild = repositoryFiles.buildLatest request
            
    promiseOfResponse = q
        .all [ promiseOfReservations, promiseOfNginxExposure, promiseOfPublicBuild, promiseOfLatestBuild ]
        .spread (reservations) ->
            winston.info 'repository was successfuly exposed on ports %s and %s', reservations.public.port, reservations.latest.port
        .catch (error) ->
            winston.error 'could not expose repository through ngnix: %s', error.message



exports.get = (request) ->
    winston.info 'received a request to retrieve repository details'
    
    if not request.repository._id then throw utility.getErrorFrom 'request is missing repository identifier'
    
    promiseOfRepository = database.Repository
        .findById request.repository._id
        .exec()
        
    promiseOfVersions = q
        .when promiseOfRepository
        .then (repository) ->
            request.repository.author = repository.author
            request.repository.name = repository.name
            
            repositoryFiles.getVersions request
            
    promiseOfReservations = reservation.get request
        
    promisesOfDetails = [
        promiseOfRepository
        promiseOfVersions
        promiseOfReservations
    ]
        
    promiseOfResponse = q
        .all promisesOfDetails
        .spread (repository, versions, reservations) ->
            winston.info 'repository details retrieved successfuly'
            
            response =
                name: repository.name
                author: repository.author
                dateOfLatestPulling: repository.dateOfLatestPulling
                dateOfLatestPublishing: repository.dateOfLatestPublishing
                versions: versions
                reservations: reservations
            
            return response
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
        
    if not request.repository.author then throw utility.getErrorFrom 'request is missing repository author'
    if not request.repository.name   then throw utility.getErrorFrom 'request is missing repository name'
    
    repository =
        author: request.repository.author
        name: request.repository.name
        
    promiseOfClonedRepository = repositoryFiles.cloneSourceIntoLatestDirectory request
    promiseOfRepositoryInDatabase = database.Repository.create repository
    
    promisesOfCreation = [
        promiseOfRepositoryInDatabase
        promiseOfClonedRepository
    ]
    
    promiseOfResponse = q
        .all promisesOfCreation
        .spread (repository) ->
            winston.info 'repository %s was successfuly created', request.repository.name
            
            return repository
        .catch (error) ->
            winston.error 'could not create repository: %s', error.message



exports.remove = (request) ->
    winston.info 'received a repository removal request for repository %s', request.repository._id
    
    if not request.repository._id then throw utility.getErrorFrom 'request is missing repository identifier'
    
    promiseOfRemovals = q.all [
        repositoryFiles.removeFromHardDrive request
        exports.hide request
    ]
    
    promiseOfRemovalFromDatabase = q
        .when promiseOfRemovals
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