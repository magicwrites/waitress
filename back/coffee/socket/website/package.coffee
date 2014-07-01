# require

winston = require 'winston'
fileSystem = require 'q-io/fs'
q = require 'q'

# private

getPackageJsonFile = (author, name, type) ->
    winston.info 'loading package file for %s %s/%s', type, author, name
    
    promiseOfPackageJson = q
        .when fileSystem.read '/var/www/' + author + '/' + name + '/' + type + '/package.json'
        .then (rawFile) ->
            packageJsonContent = JSON.parse rawFile
        .catch (error) ->
            winston.warn 'could not load package file of the %s %s/%s', type, author, name
            packageJsonContent = null

# public

exports.getVersion = (author, name, type) ->
    winston.info 'getting version for the %s %s/%s', type, author, name
    
    promiseOfVersion = q
        .when getPackageJsonFile author, name, type
        .then (packageInformation) ->
            winston.info 'got version for the %s %s/%s', type, author, name
            version = if packageInformation then packageInformation.version else null
        .catch (error) ->
            winston.error 'could not get version for the %s %s/%s', type, author, name
            version = null