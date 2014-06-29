# require

winston = require 'winston'
fileSystem = require 'q-io/fs'
_ = require 'lodash'
q = require 'q'

# private

logPrefix = 'website nginx ports: '
fileWithJsonPorts = './configuration/ports.json'

addToFile = (portsAdded) ->
    winston.info logPrefix + 'adding ports to the restricted list'
    
    promiseOfPortsFromFile = getFromFile()
    
    promiseOfAdding = q
        .when promiseOfPortsFromFile
        .then (portsFromFile) ->
            portsFromFile.push portsAdded.public # todo, assign per page?
            portsFromFile.push portsAdded.latest
            
            writeToFile portsFromFile
    
    promiseOfAdding
        .then () ->
            winston.info logPrefix + 'ports were added to the restricted list'
        .catch (error) ->
            winston.error logPrefix + 'ports could not be added to the restricted list'

writeToFile = (ports) ->
    winston.info logPrefix + 'writing to a ports file'
    
    portsFile = JSON.stringify ports, null, 4
    
    fileSystem
        .write fileWithJsonPorts, portsFile
        .then () ->
            winston.info logPrefix + 'writing to a ports file was successful'
        .catch (error) ->
            winston.error logPrefix + 'could not write a ports file'

getFromFile = () ->
    winston.info logPrefix + 'retrieving ports from a ports file'
    
    promiseOfPorts = fileSystem.read fileWithJsonPorts
    
    promiseOfPorts
        .then (portsFromFile) ->
            winston.info logPrefix + 'retrieved ports entries from a file'
            ports = JSON.parse portsFromFile
        .catch (error) ->
            winston.error logPrefix + 'could not retrieve ports from a file'
            
assignPortsForWebsite = (portsTaken) ->
    candidate = 3000
    candidate += 10 while _.contains portsTaken, candidate # todo, assign per page?

    portsAssigned =
        public: candidate
        latest: candidate + 5

    winston.info logPrefix + 'assigned ports %s and %s', portsAssigned.public, portsAssigned.latest
    
    return portsAssigned
            
# public
        
exports.setForWebsite = (author, name) ->
    winston.info logPrefix + 'setting ports for a website %s/%s', author, name
    
    promiseOfPorts = getFromFile()
    promiseOfAssignment = promiseOfPorts.then assignPortsForWebsite
    promiseOfPersistence = promiseOfAssignment.then addToFile
    
    promiseOfPersistence
        .then () ->
            winston.info logPrefix + 'ports for website are set'
            
            return promiseOfAssignment
        .catch (error) ->
            winston.error logPrefix + 'could not set ports for a website'