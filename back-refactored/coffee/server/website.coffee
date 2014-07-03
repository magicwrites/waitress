# require

winston = require 'winston'
q = require 'q'
fileSystem = require 'q-io/fs'
_ = require 'lodash'

configuration = require './../../../configuration/waitress.json'
user = require './user'
websiteReader = require './website/reader.coffee'

# public

exports.list = (request) ->
    winston.info 'received an website listing request: %s', JSON.stringify request, null, 4
    
    promiseOfAuthorization = user.isAuthorized request
    
    promiseOfResponse = q
        .when promiseOfAuthorization
        .then (isAuthorized) ->
            response = if isAuthorized then websiteReader.list() else no
        .catch (error) ->
            winston.error 'could not list websites: %s', JSON.stringify error, null, 4



exports.get = () ->
    #