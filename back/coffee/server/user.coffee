winston = require 'winston'
q = require 'q'

configuration = require './../../../configuration/waitress.json'
database = require './../database'



exports.isCreated = () ->
    winston.info 'resolving user credentials existence'
    
    promiseOfUser = database.User
        .findOne()
        .exec()
        
    promiseOfResponse = q
        .when promiseOfUser
        .then (user) ->
            isCreated = if user then yes else no
            
            winston.info 'user existence resolved as %s', isCreated
                
            return isCreated
        .catch (error) ->
            winston.error 'could not determine user existence: %s', error.message



exports.isAuthorized = (request) ->
    winston.info 'received an authorization request'
    
    promiseOfUser = database.User
        .findOne()
        .exec()
    
    promiseOfResponse = q
        .when promiseOfUser
        .then (userFromDatabase) ->
            isNameMatching = if userFromDatabase.name is request.user.name then yes else no
            isPasswordMatching = if userFromDatabase.password is request.user.password then yes else no
            isAuthorized = if isNameMatching and isPasswordMatching then yes else no
                
            winston.info 'user authorization resolved as %s', isAuthorized
            
            return isAuthorized
        .catch (error) ->
            winston.error 'could not authorize request: %s', error.message



exports.create = (request) ->
    winston.info 'received an creation request'
    
    console.log request
    
    promiseOfUser = database.User.create request.user
    
    promiseOfResponse = q
        .when promiseOfUser
        .then () ->
            winston.info 'user %s has been created successfuly', request.user.name
            
            return request.user
        .catch (error) ->
            winston.error 'could not save the credentials: %s', error.message