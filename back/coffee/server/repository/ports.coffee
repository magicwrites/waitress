# require

q = require 'q'
fileSystem = require 'q-io/fs'
winston = require 'winston'
_ = require 'lodash'

configuration = require './../../../../configuration/waitress.json'

# private

getPromiseOfTaken = () ->
    q
        .when fileSystem.read configuration.files.ports.json
        .then (fileContents) ->
            portsEntries = JSON.parse fileContents

checkPresence = (portEntriesFromFile, port) ->
    limit = configuration.ports.bases.public + configuration.ports.steps.github
    
    if port >= limit then throw 'websites ports limit reached, you will have to remove old websites if you want new'
    
    entryUsingThatPort = _.find portEntriesFromFile, (entry) ->
        condition = (entry.latest == port || entry.public == port)

    isPresent = !!entryUsingThatPort

# public

exports.get = (request) ->
    winston.info 'received a request to get %s website ports', request.repository.name
    
    promiseOfTaken = getPromiseOfTaken()
            
    promiseOfResponse = q
        .when promiseOfTaken
        .then (portsTaken) ->
            searchedEntry = _.find portsTaken, (entry) ->
                entry.author is request.repository.author and entry.name is request.repository.name
                
            ports =
                public: searchedEntry.public
                latest: searchedEntry.latest
                github: searchedEntry.github
        .catch (error) ->
            winston.error 'could not get %s website ports: %s', request.repository.name, error.message



exports.remove = (request) ->
    winston.info 'received a request to create %s website ports', request.repository.name
    
    promiseOfTaken = getPromiseOfTaken()
    
    promiseOfClearedPorts = q
        .when promiseOfTaken
        .then (portsTaken) ->
            _.remove portsTaken, (entry) ->
                entry.author is request.repository.author and entry.name is request.repository.name
            
            fileSystem.write configuration.files.ports.json, JSON.stringify portsTaken, null, 4
            
    promiseOfResponse = q
        .when promiseOfClearedPorts
        .then () ->
            winston.info 'ports for %s website are cleared', request.repository.name
        .catch (error) ->
            winston.error 'could not clear %s website ports: %s', request.repository.name, error.message



exports.create = (request) ->
    winston.info 'received a request to create %s website ports', request.repository.name
    
    promiseOfTaken = getPromiseOfTaken()
            
    promiseOfFreePorts = q
        .when promiseOfTaken
        .then (portEntriesFromFile) ->
            candidate = configuration.ports.bases.public
            candidate += 10 while checkPresence portEntriesFromFile, candidate

            freePorts =
                public: candidate
                latest: candidate + configuration.ports.steps.latest
                github: candidate + configuration.ports.steps.github
                
    promiseOfAssignment = q
        .all [
            promiseOfFreePorts
            promiseOfTaken
        ]
        .spread (portsFree, portsTaken) ->
            entry =
                author: request.repository.author
                name: request.repository.name
                public: portsFree.public
                latest: portsFree.latest
                github: portsFree.github
        
            portsTaken.push entry
            
            fileSystem.write configuration.files.ports.json, JSON.stringify portsTaken, null, 4
    
    promiseOfResponse = q
        .all [
            promiseOfFreePorts
            promiseOfAssignment
        ]
        .spread (ports) ->
            winston.info 'ports for %s website are assigned', request.repository.name
        
            response =
                public: ports.public
                latest: ports.latest
                github: ports.github
        .catch (error) ->
            winston.error 'could not create %s website ports: %s', request.repository.name, error.message