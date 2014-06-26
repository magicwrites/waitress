# require

winston = require 'winston'
fileSystem = require 'q-io/fs'
_ = require 'lodash'
q = require 'q'

# private

userFile =
    path: './configuration/user.json'

# public

exports.isCreated = () ->
    winston.info 'waitress has received an user existence status request'
    
    socket = this
    
    fileSystem.exists userFile.path
        .then (isCreated) ->
            socket.emit 'waitress user isCreated', isCreated
            winston.info 'waitress has responsed with user existence status - ' + isCreated
        .fail (error) ->
            winston.error 'waitress has failed to respond with an user existence status', error

exports.isAuthorizedProperly = (userFromClient) ->
    winston.info 'waitress is authorizing request'
    
    deferred = q.defer()
    
    fileSystem.read userFile.path
        .then (userFromFile) ->
            userFromFile = JSON.parse userFromFile
            
            if _.isEqual userFromFile, userFromClient
                winston.info 'waitress has authorized the request'
                deferred.resolve()
            else
                winston.info 'waitress has not authorized the request'
                deferred.reject()
        .fail (error) ->
            winston.error 'waitress was unable to authorize the request'
            deferred.reject error
        
    deferred.promise
            
exports.isAuthorized = (userFromClient) ->
    winston.info 'waitress has received an user authorization request'
    
    socket = this
    
    fileSystem.read userFile.path
        .then (userFromFile) ->
            userFromFile = JSON.parse userFromFile
            isAuthorized = if _.isEqual userFromFile, userFromClient then yes else no
                
            socket.emit 'waitress user isAuthorized', isAuthorized
            winston.info 'waitress has responded with user authorization - ' + isAuthorized
        .fail (error) ->
            winston.error 'waitress has failed to respond with an user authorization', error
    
exports.create = (user) ->
    winston.info 'waitress has received an user creation request'
    
    socket = this
    
    content = JSON.stringify user, null, 4
    
    fileSystem.write userFile.path, content
        .then () ->
            socket.emit 'waitress user create', user
            winston.info 'waitress has created a new user - ' + user.username
        .fail (error) ->
            winston.error 'waitress has failed to create a new user - ' + user.username, error
    