# require

winston = require 'winston'
fileSystem = require 'q-io/fs'
q = require 'q'

user = require './../user.coffee'

# public

exports.list = (data) ->
    winston.info 'waitress has received a website listing request'
    
    socket = this
    websites = []
    
    user.isAuthorizedProperly data
        .then () ->
            fileSystem
                .list '/var/www'
                .then listWebsites

    listWebsites = (authors) ->
        listingPromises = []
        
        for author in authors
            do (author) ->
                listingPromise = fileSystem
                    .list '/var/www/' + author
                    .then (repositories) ->
                        for name in repositories
                            do (name) ->
                                website =
                                    repository:
                                        author: author
                                        name: name
                                    public: ''
                                    latest: ''
                                    stored: []
                                
                                websites.push website
                        
                listingPromises.push listingPromise

        q
            .all listingPromises
            .then () ->
                winston.info 'waitress has listed %s websites', websites.length
                socket.emit 'waitress website list', websites
            .fail (error) ->
                winston.error 'waitress has failed to list websites'
                
exports.get = (data) ->
    winston.info 'waitress has received a website get request'
    
    socket = this
    websites = []
    
    user.isAuthorizedProperly data
        .then () ->
            # todo, return versions and domain data rather than mock it
            website =
                repository: data.repository
                versions:
                    public: ''
                    latest: ''
                    stored: []
                domains: []
            
            winston.info 'waitress has sent %s/%s website data', data.repository.author, data.repository.name
            socket.emit 'waitress website get', website