# require

websocket = require 'socket.io'
winston = require 'winston'

utility = require './utility.coffee'
user = require './socket/user.coffee'
website = require './socket/website.coffee'

# private

utility.configurations.setLoggingFor winston
io = websocket.listen 2001

# execute

io.sockets.on 'connection', (socket) ->
    winston.info 'web socket has received a connection'
    
    socket.on 'waitress user isCreated', user.isCreated
    socket.on 'waitress user isAuthorized', user.isAuthorized
    socket.on 'waitress user create', user.create
    
    socket.on 'waitress website publish', website.publish
    socket.on 'waitress website create', website.create
    socket.on 'waitress website remove', website.remove
    socket.on 'waitress website list', website.list
    socket.on 'waitress website get', website.get
    
    socket.on 'disconnect', () ->
        winston.info 'web socket has disconnected'
    
winston.info 'web sockets have been opened'