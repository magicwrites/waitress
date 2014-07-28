winston = require 'winston'
q = require 'q'

database = require './../database'
utility = require './../utility'
configuration = require './../../../configuration/waitress.json'



exports.list = (request) ->
    winston.info 'received a log listing request limited to %s logs', request.limit
    
    promiseOfLogs = database.Log
        .find()
        .sort
            timestamp: -1
        .limit request.limit || configuration.logs.limit
        .exec()
        
    promiseOfResponse = q
        .when promiseOfLogs
        .then (logs) ->
            winston.info 'log listing completed successfuly, found %s logs', logs.length
            
            return logs
        .catch (error) ->
            winston.error 'could not list logs: %s', error.message