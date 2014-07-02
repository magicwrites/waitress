# require

socket = require 'socket.io'
winston = require 'winston'
q = require 'q'
fileSystem = require 'q-io/fs'

utility = require './utility.coffee'
user = require './server/user.coffee'
#website = require './socket/website.coffee'

# private

port = 2005
utility.configurations.setLoggingFor winston
io = socket.listen port

prepareEvent = (eventName, process) ->
    socket.on eventName, getHandlerFunctionFrom eventName, process

getHandlerFunctionFrom = (eventName, processFunction) ->
    handlerFunction = (request) ->
        promise = q
            .when processFunction request
            .then (response) ->
                socket.emit eventName, response
                winston.info 'server handled the request without errors'
            .catch (error) ->
                socket.emit eventName, false
                winston.error 'server could not handle the request'
                winston.error JSON.stringify error, null, 4
                
    return handlerFunction

# execute

io.sockets.on 'connection', (socket) ->
    winston.info 'web socket has received a connection'
    console.log 'doh'
    
    socket.on 'waitress user isCreated', () ->
        console.log 'test'
        
        q   
            .when fileSystem.exists 'configuration/user.json'
            .then (result) ->
                console.log 'test result', result
                socket.emit 'waitress user isCreated', result
    
#    prepareEvent 'waitress user isCreated', user.isCreated    
#        
#    socket.on 'waitress user isAuthorized', user.isAuthorized
#    socket.on 'waitress user create', user.create
#    
#    socket.on 'waitress website publish', website.publish
#    socket.on 'waitress website create', website.create
#    socket.on 'waitress website remove', website.remove
#    socket.on 'waitress website list', website.list
#    socket.on 'waitress website get', website.get
    
    socket.on 'disconnect', () ->
        winston.info 'web socket user has disconnected'
    
winston.info 'web sockets server is working on port %s', port