# require

q = require 'q'
fileSystem = require 'q-io/fs'

configuration = require './../../../configuration/waitress.json'

# public

exports.isCreated = () ->
    promise = fileSystem.exists configuration.files.user.json
    
exports.isAuthorized = (request) ->
    promiseOfUser = fileSystem.read configuration.files.user.json