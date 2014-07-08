# require

socket = require 'socket.io'
winston = require 'winston'
q = require 'q'
fileSystem = require 'q-io/fs'

configuration = require './../../configuration/waitress.json'
utility = require './utility'
user = require './server/user'
website = require './server/website'

# private

utility.setLoggingFor winston

# execute

io = socket.listen configuration.ports.server

io.sockets.on 'connection', (socket) ->
    winston.info 'web socket has received a connection'
    
    utility.handle socket, 'waitress user isAuthorized', user.isAuthorized
    utility.handle socket, 'waitress user isCreated', user.isCreated
    utility.handle socket, 'waitress user create', user.create
    
    utility.handle socket, 'waitress website create', website.create, user.isAuthorized

    socket.on 'disconnect', () ->
        winston.info 'web socket user has disconnected'

winston.info 'web sockets server is working on port %s', configuration.ports.server