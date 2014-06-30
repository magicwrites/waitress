# require

winston = require 'winston'
fileSystem = require 'q-io/fs'
q = require 'q'

user = require './../user.coffee'
nginxPorts = require './nginx/ports.coffee'

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
            
            q
                .when nginxPorts.getForWebsite data.repository.author, data.repository.name
                .then (ports) ->
                    website =
                        ports:
                            latest: ports.latest
                            public: ports.public
                        repository: data.repository
                        versions:
                            public: '1.0.0'
                            latest: '1.21.3'
                            stored: [
                                '0.5.0'
                                '1.0.0'
                            ]
                        domains: [
                            'sample.domain.net'
                            '*.domain.net'
                        ]

                    winston.info 'waitress has sent %s/%s website data', data.repository.author, data.repository.name
                    socket.emit 'waitress website get', website