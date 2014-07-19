# require

q = require 'q'
fileSystem = require 'q-io/fs'
winston = require 'winston'

websiteUtility = require './utility'
configuration = require './../../../../configuration/waitress.json'

# private

# public

exports.get = (request) ->
    winston.info 'received a request to get %s website versions', request.repository.name
    
    websiteName = websiteUtility.getWebsiteNameFrom request
    directories = websiteUtility.getDirectoriesFrom request, websiteName
    files = websiteUtility.getPackageFilesFrom request, websiteName, directories
    
    promiseOfPublic = q
        .when fileSystem.exists files.public
        .then (isPresent) ->
            promise = if isPresent then fileSystem.read files.public else undefined

    promiseOfLatest = q
        .when fileSystem.exists files.latest
        .then (isPresent) ->
            promise = if isPresent then fileSystem.read files.latest else undefined
    
    promisesOfVersions = [
        promiseOfPublic
        promiseOfLatest
    ]
            
    promiseOfResponse = q
        .all promisesOfVersions
        .spread (packagePublic, packageLatest) ->
            if packagePublic then packagePublic = JSON.parse packagePublic
            if packageLatest then packageLatest = JSON.parse packageLatest
            
            versions =
                public: packagePublic?.version
                latest: packageLatest?.version
                stored: [] # todo
        .catch (error) ->
            winston.error 'could not get %s website versions: %s', request.repository.name, error.message