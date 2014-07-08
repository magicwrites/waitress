# require

winston = require 'winston'
q = require 'q'
fileSystem = require 'q-io/fs'

configuration = require './../../../configuration/waitress.json'
user = require './user'
websitePorts = require './website/ports'
websiteNginx = require './website/nginx'
websiteFiles = require './website/files'
websiteGithub = require './website/github'

# public

exports.list = (request) ->
    winston.info 'received a website listing request'
    
    promiseOfResponse = q
        .when fileSystem.list configuration.directories.websites
        .then (list) ->
            listing = []
            
            for element in list
                replaced = configuration.characters.separators.website.replaced
                replacer = configuration.characters.separators.website.replacer
                
                listing.push element.replace replaced, replacer
                
            response = listing
        .catch (error) ->
            winston.error 'could not list websites: %s', error.message



exports.create = (request) ->
    winston.info 'received a website creation request'
    
    promiseOfPorts = websitePorts.create request
    promiseOfStructure = websiteFiles.create request

    promiseOfGithub = q
        .all [
            promiseOfPorts
            promiseOfStructure
        ]
        .spread (ports) ->
            websiteGithub.create request, ports

    promiseOfNginx = q
        .all [
            promiseOfPorts
            promiseOfGithub
        ]
        .spread (ports) ->
            websiteNginx.create request, ports

    promiseOfResponse = q
        .all [
            promiseOfNginx
            promiseOfGithub
        ]
        .spread (nginx, github) ->
            winston.info 'website %s was successfuly created', request.repository.name
        
            response =
                nginx: nginx
                github: github
        .catch (error) ->
            winston.error 'could not create website: %s', error.message