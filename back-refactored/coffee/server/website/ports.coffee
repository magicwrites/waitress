# require

q = require 'q'
fileSystem = require 'q-io/fs'
winston = require 'winston'

configuration = require './../../../../configuration/waitress.json'

# private

checkPresence = (portEntriesFromFile, port) ->
    limit = configuration.ports.bases.public + configuration.ports.steps.github
    
    if port >= limit then throw 'websites ports limit reached, you will have to remove old websites if you want new'
    
    entryUsingThatPort = _.find portEntriesFromFile, (entry) ->
        condition = (entry.latest == port || entry.public == port)

    isPresent = !!entryUsingThatPort

# public

exports.create = (request) ->
    winston.info 'received a request to create %s website ports', request.repository.name
    
    promiseOfTaken = q
        .when fileSystem.read configuration.files.ports.json
        .then (fileContents) ->
            portsEntries = JSON.parse fileContents
            
    promiseOfFreePorts = q
        .when promiseOfTaken
        .then (portEntriesFromFile) ->
            candidate = configuration.ports.bases.website
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
            winston.info 'ports for %s website are assigned as: %s', request.repository.name, JSON.stringify, ports, null, 4
        
            response =
                public: ports.public
                latest: ports.latest
                github: ports.github
        .catch (error) ->
            winston.error 'could not create %s website ports: %s', request.repository.name, JSON.stringify error, null, 4 