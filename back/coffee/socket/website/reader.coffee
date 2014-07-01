# require

winston = require 'winston'
fileSystem = require 'q-io/fs'
q = require 'q'

user = require './../user.coffee'
nginxPorts = require './nginx/ports.coffee'
websitePackage = require './package.coffee'

# public

exports.list = (data) ->
    winston.info 'waitress has received a website listing request'
    
    socket = this
    websites = []
    
    # todo, rewrite this crap
    
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
                                    public: websitePackage.getVersion author, name, 'public'
                                    latest: websitePackage.getVersion author, name, 'latest'
                                    stored: []

                                websites.push website
                        
                listingPromises.push listingPromise

        q
            .all listingPromises
            .then () ->
                winston.info 'waitress has listed %s websites', websites.length
                socket.emit 'waitress website list', websites
            .fail (error) ->
                console.log error
                winston.error 'waitress has failed to list websites'
                
exports.get = (request) ->
    winston.info 'waitress has received a website get request'
    
    socket = this
    author = request.repository.author
    name = request.repository.name 
    websites = []
    
    user.isAuthorizedProperly request
        .then () ->
            # todo, return versions and domain data rather than mock it
            promises = [
                nginxPorts.getForWebsite author, name
                websitePackage.getVersion author, name, 'public'
                websitePackage.getVersion author, name, 'latest'
            ]
            
            q
                .all promises
                .spread (ports, publicVersion, latestVersion) ->
                    website =
                        ports:
                            latest: ports.latest
                            public: ports.public
                        repository:
                            author: author
                            name: name
                        versions:
                            public: publicVersion
                            latest: latestVersion
                            stored: [
                                '0.5.0'
                                '1.0.0'
                            ]
                        domains: [
                            'sample.domain.net'
                            '*.domain.net'
                        ]

                    winston.info 'waitress has sent %s/%s website data', author, name
                    socket.emit 'waitress website get', website
                .catch (error) ->
                    winston.error 'could not sent %s/%s website data', author, name