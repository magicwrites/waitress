# require

socket = require 'socket.io'
winston = require 'winston'
q = require 'q'

configuration = require './../../configuration/waitress.json'
database = require './database'
utility = require './utility'
user = require './server/user'
website = require './server/website'



do () ->
    utility.setLoggingFor winston
    
    
    
    promiseOfDatabaseConnection = database.connect()

    promiseOfWebsockets = q
        .when promiseOfDatabaseConnection
        .then () ->
            io = socket.listen configuration.ports.server

            io.sockets.on 'connection', (socket) ->
                winston.info 'web socket has received a connection'

                utility.handle socket, 'waitress user isAuthorized', user.isAuthorized
                utility.handle socket, 'waitress user isCreated', user.isCreated
                utility.handle socket, 'waitress user create', user.create

                utility.handle socket, 'waitress website create', website.create, user.isAuthorized    
                utility.handle socket, 'waitress website remove', website.remove, user.isAuthorized
                utility.handle socket, 'waitress website list', website.list, user.isAuthorized
                utility.handle socket, 'waitress website get', website.get, user.isAuthorized

                socket.on 'disconnect', () ->
                    winston.info 'web socket user has disconnected'

            winston.info 'web sockets server is working on port %s', configuration.ports.server
            
        .catch (error) ->
            winston.error 'could not establish websockets server %s', error.message