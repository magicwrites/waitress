winston = require 'winston'
q = require 'q'

configuration = require './../../../configuration/waitress.json'
database = require './../database'
utility = require './../utility'



exports.ensureExistence = () ->
    winston.info 'ensuring setting existence'

    promiseOfSetting = database.Setting
        .findOne()
        .exec()

    promiseOfEnsurance = q
        .when promiseOfSetting
        .then (setting) ->
            promiseOfEnsurance = if setting then no else database.Setting.create {}

    promiseOfResponse = q
        .when promiseOfEnsurance
        .then (ensuranceResult) ->
            winston.info 'setting ensured, creation need resolved to: %s', if ensuranceResult then yes else no
        .catch (error) ->
            winston.error 'could not ensure setting presence: %s', error.message



#exports.set = (request) ->
#    winston.info 'received a github setting request'
#    
#    promiseOfGithubRemoval = database.Github
#        .remove()
#        .exec()
#    
#    promiseOfGithubSetting = q
#        .when promiseOfGithubRemoval
#        .then () ->
#            database.Github.create request.github
#    
#    promiseOfResponse = q
#        .when promiseOfGithubSetting
#        .then () ->
#            winston.info 'github has been set successfuly with %s and %s', request.github.username, request.github.password
#            
#            return request.github
#        .catch (error) ->
#            winston.error 'could not set github account data: %s', error.message
#
#
#
#exports.get = (request) ->
#    winston.info 'received a github getting request'
#    
#    promiseOfGithub = database.Github
#        .findOne()
#        .exec()
#    
#    promiseOfResponse = q
#        .when promiseOfGithub
#        .then (github) ->
#            winston.info 'github has been retrieved successfuly with %s and %s', github.username, github.password
#            
#            return github
#        .catch (error) ->
#            winston.error 'could not retrieve github account data: %s', error.message