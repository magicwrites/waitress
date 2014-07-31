winston    = require 'winston'
fileSystem = require 'q-io/fs'

q = require 'q'

database = require './../database'
utility  = require './../utility'
nginx    = require './nginx'



extractServerNamesFrom = (domains) ->
    serverNames = ''
    
    for domain in domains
        serverNames += domain.name + ' '
        
    serverNames.slice 0, -1 # chop off the last empty space
    
    

addServerNamesFrom = (domains, publicEntry) ->
    serverNames = extractServerNamesFrom domains
    
    searchResult = publicEntry.search 'server_name '
    isAnyDomainDefined = searchResult >= 0
    
    if  isAnyDomainDefined
        publicEntry = publicEntry.replace /server_name .*;/, 'server_name ' + serverNames + ';'
    else
        publicEntry = publicEntry.replace 'server {', 'server {\n    server_name ' + serverNames + ';\n'
    
    return publicEntry



exports.remove = (request) ->
    if not request.domain     then throw utility.getErrorFrom 'request is missing domain data'
    if not request.domain._id then throw utility.getErrorFrom 'request is missing domain identifier'
    
    winston.info 'received a request to remove a domain %s', request.domain._id
    
    promiseOfRemoval = database.Domain
        .findByIdAndRemove request.domain._id
        .exec()
    
    promiseOfUpdate = q
        .when promiseOfRemoval
        .then () ->
            exports.update request
        
    promiseOfResponse = q
        .when promiseOfUpdate
        .then (domains) ->
            winston.info 'domain %s had been successfuly removed', request.domain._id
        .catch (error) ->
            winston.error 'could not remove repository domain: %s', error.message



exports.list = (request) ->
    if not request.repository     then throw utility.getErrorFrom 'request is missing repository data'
    if not request.repository._id then throw utility.getErrorFrom 'request is missing repository identifier'
    
    winston.info 'received a request to list domains for repository %s', request.repository._id
    
    promiseOfDomains = database.Domain
        .find()
        .exec()
        
    promiseOfResponse = q
        .when promiseOfDomains
        .then (domains) ->
            winston.info 'domain for repository %s had been successfuly listed, found ', request.repository._id, domains.length
            
            return domains
        .catch (error) ->
            winston.error 'could not list domains for a repository: %s', error.message



exports.create = (request) ->
    if not request.repository     then throw utility.getErrorFrom 'request is missing repository data'
    if not request.domain         then throw utility.getErrorFrom 'request is missing domain data'
    if not request.repository._id then throw utility.getErrorFrom 'request is missing repository identifier'
    if not request.domain.name    then throw utility.getErrorFrom 'request is missing domain name'
    
    winston.info 'received a request to assign a %s domain to a repository %s', request.domain.name, request.repository._id
    
    domain =
        name: request.domain.name
        repository: request.repository._id
    
    promiseOfDomainInDatabase = database.Domain.create domain
    
    promiseOfUpdate = q
        .when promiseOfDomainInDatabase
        .then () ->
            exports.update request
    
    promiseOfResponse = q
        .when promiseOfUpdate
        .then () ->
            winston.info 'domain %s has been successfuly assigned to a repository', request.domain.name
        .catch (error) ->
            winston.error 'could not assign the domain to the repository: %s', error.message



exports.update = (request) ->
    if not request.repository     then throw utility.getErrorFrom 'request is missing repository data'
    if not request.repository._id then throw utility.getErrorFrom 'request is missing repository identifier'
    
    winston.info 'received a request to update domains of the %s repository', request.repository._id

    promiseOfDomains = database.Domain
        .find { repository: request.repository._id }
        .exec()
        
    promiseOfNginxPaths = nginx.getPaths request
        
    promiseOfPublicNginxEntry = q
        .when promiseOfNginxPaths
        .then (nginxPaths) ->
            fileSystem.read nginxPaths.files.publicFile
    
    promiseOfUpdatedContent = q
        .all [ promiseOfDomains, promiseOfPublicNginxEntry ]
        .spread (domains, publicEntry) ->
            publicEntry = addServerNamesFrom domains, publicEntry
                
    promiseOfUpdatedPublicNginxEntry = q
        .all [ promiseOfNginxPaths, promiseOfUpdatedContent ]
        .spread (nginxPaths, updatedEntry) ->
            console.log 'writing'
            fileSystem.write nginxPaths.files.publicFile, updatedEntry
        
    promiseOfNginxRestart = q
        .when promiseOfUpdatedPublicNginxEntry
        .then () ->
            console.log 'nginx restart'
            utility.runShell 'nginx/restart.sh'
        
    promiseOfResponse = q
        .when promiseOfNginxRestart
        .then () ->
            winston.info 'domains of the repository %s were updated successfuly', request.repository._id
        .catch (error) ->
            winston.error 'could not update domains: %s', error.message