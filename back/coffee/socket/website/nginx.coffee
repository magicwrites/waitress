# require

winston = require 'winston'
fileSystem = require 'q-io/fs'
childProcess = require 'child-process-promise'
q = require 'q'
_ = require 'lodash'

nginxPorts = require './nginx/ports.coffee'

# private

logPrefix = 'website nginx: '

directories =
    sites:
        available: '/etc/nginx/sites-available'
        enabled: '/etc/nginx/sites-enabled'
        
ensureDirectoriesExistence = () ->
    winston.info logPrefix + 'ensuring directorise existence'
    
    promisesOfDirectories = [
        fileSystem.makeTree directories.sites.available
        fileSystem.makeTree directories.sites.enabled
    ]
    
    q
        .all promisesOfDirectories
        .then () ->
            winston.info logPrefix + 'directories existence ensured'
        .catch (error) ->
            winston.error logPrefix + 'directories existence could not be ensured'

addVirtualServer = (type, port, author, name) ->
    winston.info logPrefix + 'adding %s virtual server on port %s', type, port
    
    fileName = author + '+' + name + '+' + type
    
    filePaths =
        available: directories.sites.available + '/' + fileName
        enabled: directories.sites.enabled + '/' + fileName
    
    promiseOfTemplate = q
        .when fileSystem.read 'back/templates/nginx/websites/' + type
        .then (template) ->
            template = template.replace '{{ some-port }}', port
            template = template.replace '{{ repository-author }}', author
            template = template.replace '{{ repository-name }}', name

            entry = template
            
    promiseOfAvailability = q
        .when promiseOfTemplate
        .then (template) ->
            fileSystem.write filePaths.available, template
            
    promiseOfEstablishment = q
        .when promiseOfAvailability
        .then fileSystem.symbolicLink filePaths.enabled, filePaths.available, 'file'
        .then () ->
            winston.info logPrefix + '%s nginx virtual server for %s/%s was created on port %s', type, author, name, port
        .catch (error) ->
            winston.error logPrefix + 'could not create %s virtual server', type
            
addVirtualServers = (repositoryAuthor, repositoryName, portsAssigned) ->
    promisesOfVirtualServers = [
        addVirtualServer 'public', portsAssigned.public, repositoryAuthor, repositoryName
        addVirtualServer 'latest', portsAssigned.latest, repositoryAuthor, repositoryName
    ]
    
    q
        .all promisesOfVirtualServers 
        .then () ->
            winston.info logPrefix + 'virtual servers were added successfuly'
        .catch (error) ->
            winston.error logPrefix + 'adding virtual servers failed'

restartService = () ->
    winston.info logPrefix + 'restarting nginx service'
    
    childProcess
        .spawn 'service', ['nginx', 'restart']
        .then () ->
            winston.info logPrefix + 'nginx service has been restarted'
        .catch (error) ->
            winston.error logPrefix + 'could not restart nginx service'

# public

exports.create = (request) ->
    repository = request.repository
    
    winston.info logPrefix + 'creating %s/%s website nginx environment', repository.author, repository.name
    
    promiseOfPorts = nginxPorts.setForWebsite request.repository.author, request.repository.name
    promiseOfDirectories = ensureDirectoriesExistence()
    
    initialPromises = [
        promiseOfPorts
        promiseOfDirectories
    ]
    
    promiseOfNginxVirtualServers = q
        .all initialPromises
        .spread (ports, directoreis) ->
            addVirtualServers request.repository.author, request.repository.name, ports
            
    promiseOfRestart = q
        .when promiseOfNginxVirtualServers
        .then restartService
    
    crucialPromises = [
        promiseOfRestart
        promiseOfPorts
    ]
    
    q
        .all crucialPromises
        .spread (restart, ports) ->
            winston.info logPrefix + 'created nginx environment for website %s/%s', repository.author, repository.name
            return ports
        .catch (error) ->
            console.log error
            winston.error logPrefix + 'could not create nginx environment for website %s/%s', repository.author, repository.name
            
