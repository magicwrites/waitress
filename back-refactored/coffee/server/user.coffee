# require

winston = require 'winston'
q = require 'q'
fileSystem = require 'q-io/fs'
_ = require 'lodash'

configuration = require './../../../configuration/waitress.json'

# public

exports.isCreated = () ->
    winston.info 'resolving user credentials existence'
    
    promise = fileSystem.exists configuration.files.user.json



exports.isAuthorized = (request) ->
    winston.info 'received an authorization request: %s', JSON.stringify request, null, 4
    
    promise = q
        .when fileSystem.read configuration.files.user.json
        .then (fileContent) ->
            userFromFile = JSON.parse fileContent
            isAuthorized = if _.isEqual userFromFile, request.user then yes else no
        .catch (error) ->
            winston.error 'could not authorize request: %s', JSON.stringify error, null, 4



exports.create = (request) ->
    winston.info 'received an creation request: %s', JSON.stringify request, null, 4
    
    fileContent = JSON.stringify request.user, null, 4
    
    promise = q
        .when fileSystem.write configuration.files.user.json, fileContent
        .then () ->
            return request.user
        .catch (error) ->
            winston.error 'could not save the credential file: %s', JSON.stringify error, null, 4