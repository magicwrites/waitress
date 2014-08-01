socket  = require 'socket.io'
winston = require 'winston'
q       = require 'q'

configuration   = require './../../configuration/waitress.json'
database        = require './database'
utility         = require './utility'
user            = require './server/user'
github          = require './server/github'
repository      = require './server/repository'
repositoryFiles = require './server/repository/files'
log             = require './server/log'
setting         = require './server/setting'
domain          = require './server/domain'



do () ->
    utility.setConsoleLoggingFor winston
    
    promiseOfDatabaseConnection = database.connect()
    
    promiseOfSettingEnsurance = q
        .when promiseOfDatabaseConnection
        .then () ->
            promiseOfSettingEnsurance = setting.ensureExistence()
            
    promiseOfRepositories = q
        .when promiseOfDatabaseConnection
        .then () ->
            promiseOfRepositories = repository.list()
            
    promiseOfBuiltRepositories = q
        .when promiseOfRepositories
        .then (repositories) ->
            promises = []
            
            for repository in repositories
                request =
                    repository:
                        _id: repository._id.toString()
                
                promises.push repositoryFiles.buildLatest request
                promises.push repositoryFiles.buildPublic request
                
            q.all promises

    promiseOfWebsockets = q
        .all [ promiseOfDatabaseConnection, promiseOfSettingEnsurance, promiseOfBuiltRepositories ]
        .then () ->
            winston.info 'initialization of the waitress completed'
            
            io = socket.listen configuration.ports.server

            io.sockets.on 'connection', (socket) ->
                winston.info 'web socket has received a connection'

                utility.handle socket, 'waitress user isAuthorized', user.isAuthorized
                utility.handle socket, 'waitress user isCreated', user.isCreated
                utility.handle socket, 'waitress user create', user.create
                
                utility.handle socket, 'waitress github isSet', github.isSet
                utility.handle socket, 'waitress github set', github.set

                utility.handle socket, 'waitress repository create', repository.create, user.isAuthorized    
                utility.handle socket, 'waitress repository remove', repository.remove, user.isAuthorized
                utility.handle socket, 'waitress repository list', repository.list, user.isAuthorized
                utility.handle socket, 'waitress repository get', repository.get, user.isAuthorized
                utility.handle socket, 'waitress repository expose', repository.expose, user.isAuthorized
                utility.handle socket, 'waitress repository hide', repository.hide, user.isAuthorized
                utility.handle socket, 'waitress repository publish', repository.publish, user.isAuthorized
                utility.handle socket, 'waitress repository pull', repository.pull, user.isAuthorized
                
                utility.handle socket, 'waitress log list', log.list, user.isAuthorized
                
                utility.handle socket, 'waitress domain create', domain.create, user.isAuthorized
                utility.handle socket, 'waitress domain list', domain.list, user.isAuthorized
                utility.handle socket, 'waitress domain remove', domain.remove, user.isAuthorized

                socket.on 'disconnect', () ->
                    winston.info 'web socket user has disconnected'

            winston.info 'web sockets server is working on port %s', configuration.ports.server
            
        .catch (error) ->
            winston.error 'could not initialize waitress and establish websockets server %s', error.message