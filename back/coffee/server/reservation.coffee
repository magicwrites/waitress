winston = require 'winston'
q = require 'q'
_ = require 'lodash'

database = require './../database'
utility = require './../utility'

configuration = require './../../../configuration/waitress.json'



exports.get = (request) ->
    winston.info 'received a request to retrieve reservation details for a repository %s', request.repository._id
    
    if not request.repository._id then throw utility.getErrorFrom 'request is missing repository identifier'
        
    promiseOfReservations = database.Reservation
        .find
            repository: request.repository._id
        .exec()
    
    promiseOfResponse = q
        .when promiseOfReservations
        .then (reservations) ->
            winston.info 'retrieved reservation data for repository', request.repository._id
            
            return reservations
        .catch (error) ->
            winston.error 'could not retrieve reservations data: %s', error.message
    
    

exports.create = (request) ->
    winston.info 'received a request to reserve certain ports'
    
    if not request.repository._id then throw utility.getErrorFrom 'request is missing repository identifier'
    
    promiseOfReservations = database.Reservation
        .find()
        .exec()
        
    promiseOfPublicReservation = q
        .when promiseOfReservations
        .then (reservations) ->
            basePort = configuration.ports.bases.public
            basePort += configuration.ports.steps.repository while _.find reservations, { port: basePort }
                
            portLimit = configuration.ports.bases.public + configuration.ports.steps.github
            
            if basePort >= portLimit then throw utility.getErrorFrom 'repository ports limit exceeded'
                
            promiseOfReservation = database.Reservation.create
                port: basePort
                role: 'public'
                repository: request.repository._id
                
    promiseOfLatestReservation = q
        .when promiseOfReservations
        .then (reservations) ->
            basePort = configuration.ports.bases.public + configuration.ports.steps.latest
            basePort += configuration.ports.steps.repository while _.find reservations, { port: basePort }
                
            portLimit = configuration.ports.bases.public + configuration.ports.steps.github
            
            if basePort >= portLimit then throw utility.getErrorFrom 'repository ports limit exceeded'
                
            promiseOfReservation = database.Reservation.create
                port: basePort
                role: 'latest'
                repository: request.repository._id
                
    promiseOfReservations = q
        .all [ promiseOfPublicReservation, promiseOfLatestReservation ]
        .spread (publicReservation, latestReservation) ->
            reservations =
                public: publicReservation
                latest: latestReservation
                
    promiseOfResponse = q
        .when promiseOfReservations
        .then (reservations) ->
            winston.info 'ports reservation assigned successfuly as %s and %s', reservations.public.port, reservations.latest.port
            
            return reservations
        .catch (error) ->
            winston.error 'could not reserve ports: %s', error.message