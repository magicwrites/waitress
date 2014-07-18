# require

winston = require 'winston'
q = require 'q'
fileSystem = require 'q-io/fs'

configuration = require './../../../configuration/waitress.json'
database = require './../database'
user = require './user'
websitePorts = require './website/ports'
websiteNginx = require './website/nginx'
websiteFiles = require './website/files'
websiteGithub = require './website/github'
websiteVersions = require './website/versions'

# public

exports.get = (request) ->
    winston.info 'received a website get information request'
    
    promisesOfInformation = [
        websitePorts.get request
        websiteVersions.get request
    ]

    promiseOfResponse = q
        .all promisesOfInformation
        .spread (ports, versions) ->
            response =
                ports: ports
                versions: versions
        .catch (error) ->
            winston.error 'could not get website information: %s', error.message



exports.list = (request) ->
    winston.info 'received a website listing request'
    
    promiseOfWebsites = database.Website
        .find()
        .populate 'repository'
        .exec()
        
    promiseOfResponse = q
        .when promiseOfWebsites
        .then (websites) ->
            winston.info 'website listing completed successfuly, found %s websites', websites.length
            
            return websites
        .catch (error) ->
            winston.error 'could not list websites: %s', error.message
    
#    promiseOfResponse = q
#        .when fileSystem.list configuration.directories.websites
#        .then (list) ->
#            listing = []
#            
#            for element in list
#                splitted = element.split configuration.characters.separators.website.replaced
#                
#                entry =
#                    repository:
#                        author: splitted[0]
#                        name: splitted[1]
#                
#                listing.push entry
#                
#            response = listing
#        .catch (error) ->
#            winston.error 'could not list websites: %s', error.message



exports.create = (request) ->
    winston.info 'received a website creation request'
    
    promiseOfRepository = database.Repository.create request.repository
    
    promiseOfWebsite = q
        .when promiseOfRepository
        .then (repository) ->
            website =
                repository: repository
                reservations: []
            
            database.Website.create website
    
    promiseOfResponse = q
        .when promiseOfWebsite
        .then (website) ->
            winston.info 'website %s was successfuly created', request.repository.name
            
            return website
        .catch (error) ->
            winston.error 'could not create website: %s', error.message
    
#    promiseOfPorts = websitePorts.create request
#    promiseOfStructure = websiteFiles.create request
#
#    promiseOfGithub = q
#        .all [
#            promiseOfPorts
#            promiseOfStructure
#        ]
#        .spread (ports) ->
#            websiteGithub.create request, ports
#
#    promiseOfNginx = q
#        .all [
#            promiseOfPorts
#            promiseOfGithub
#        ]
#        .spread (ports) ->
#            websiteNginx.create request, ports
#
#    promiseOfResponse = q
#        .all [
#            promiseOfNginx
#            promiseOfGithub
#        ]
#        .spread (nginx, github) ->
#            winston.info 'website %s was successfuly created', request.repository.name
#        
#            response =
#                nginx: nginx
#                github: github
#        .catch (error) ->
#            winston.error 'could not create website: %s', error.message
            
            
            
exports.remove = (request) ->
    winston.info 'received a website creation request'
    
    promisesOfRemovals = [
        websiteNginx.remove request
        websitePorts.remove request
        websiteGithub.remove request
    ]

    promiseOfFilesRemoval = q
        .all promisesOfRemovals
        .then () ->
            websiteFiles.remove request

    promiseOfResponse = q
        .when promiseOfFilesRemoval
        .then () ->
            winston.info 'website %s was successfuly removed', request.repository.name
        .catch (error) ->
            winston.error 'could not remove website: %s', error.message