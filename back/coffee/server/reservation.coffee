# require

winston = require 'winston'
q = require 'q'
_ = require 'lodash'

database = require './../database'
utility = require './../utility'

configuration = require './../../../configuration/waitress.json'

# public

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
            basePort += 10 while _.find reservations, { port: basePort }
                
            promiseOfReservation = database.Reservation.create
                port: basePort
                role: 'public'
                repository: request.repository._id
                
    promiseOfLatestReservation = q
        .when promiseOfReservations
        .then (reservations) ->
            basePort = configuration.ports.bases.public + 5
            basePort += 10 while _.find reservations, { port: basePort }
                
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