winston = require 'winston'
q = require 'q'

configuration = require './../../../configuration/waitress.json'
database = require './../database'



exports.isSet = () ->
    winston.info 'resolving github account existence'
        
    promiseOfResponse = q
        .when exports.get()
        .then (github) ->
            isSet = if github then yes else no
            
            winston.info 'github account existence resolved as %s', isSet
                
            result = if isSet then github else null
        .catch (error) ->
            winston.error 'could not determine github account existence: %s', error.message



exports.set = (request) ->
    winston.info 'received a github setting request'
    
    promiseOfGithubRemoval = database.Github
        .remove()
        .exec()
    
    promiseOfGithubSetting = q
        .when promiseOfGithubRemoval
        .then () ->
            database.Github.create request.github
    
    promiseOfResponse = q
        .when promiseOfGithubSetting
        .then () ->
            winston.info 'github has been set successfuly with %s and %s', request.github.username, request.github.password
            
            return request.github
        .catch (error) ->
            winston.error 'could not set github account data: %s', error.message



exports.get = (request) ->
    winston.info 'received a github getting request'
    
    promiseOfGithub = database.Github
        .findOne()
        .exec()
    
    promiseOfResponse = q
        .when promiseOfGithub
        .then (github) ->
            winston.info 'github has been retrieved successfuly with %s and %s', github.username, github.password
            
            return github
        .catch (error) ->
            winston.error 'could not retrieve github account data: %s', error.message