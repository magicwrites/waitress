# require

websocket = require 'socket.io'
winston = require 'winston'

currentDirectory = process.cwd() + '/back/coffee/';

utility = require currentDirectory + 'utility.coffee'
user = require currentDirectory + 'socket/user.coffee'

# private

utility.configurations.setLoggingFor winston
io = websocket.listen 2001

# execute

io.sockets.on 'connection', (socket) ->
    winston.info 'web socket has received a connection'
    
    socket.on 'waitress user isCreated', user.isCreated
    socket.on 'waitress user isAuthorized', user.isAuthorized
    socket.on 'waitress user create', user.create
    
    socket.on 'disconnect', () ->
        winston.info 'web socket has disconnected'
    
winston.info 'web sockets have been opened'