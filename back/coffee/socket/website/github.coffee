# require

q = require 'q'
forever = require 'forever-monitor'

# public

exports.createListener = (request) ->
    winston.info 'creating website listener on port %s', request.port
    
    portForListener = request.ports.public + 3000
    
    commands = [
        'back/coffee/listener/github.coffee'
        portForListener
        request.repository.author
        request.repository.name
        request.user.name
        request.user.password
    ]

    options =
        command: 'coffee'
        logFile: 'log/forever/' + request.repository.author + '+' + request.repository.name

    child = forever.start commands, options

# test
    
sampleRequest =
    port: 6000
    user:
        name: 'magicwrites'
        password: '123'
    repository:
        author: 'magicwrites'
        name: 'personal-website'

exports.createListener sampleRequest