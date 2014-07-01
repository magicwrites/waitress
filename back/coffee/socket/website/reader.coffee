# require

winston = require 'winston'
fileSystem = require 'q-io/fs'
q = require 'q'
_ = require 'lodash'

user = require './../user.coffee'
nginxPorts = require './nginx/ports.coffee'
websitePackage = require './package.coffee'

# public

exports.list = (request) ->
    winston.info 'waitress has received a website listing request'
    
    socket = this
    websites = []
    
    promiseOfAuthorization = user.isAuthorizedProperly request
    
    promiseOfRepositoryAuthors = q
        .when promiseOfAuthorization
        .then () ->
            fileSystem.list '/var/www'
            
    # this is awful, do not develop it further, rather rewrite or remove altogether

    promiseOfWebsites = q
        .when promiseOfRepositoryAuthors
        .then (authors) ->
            promisesOfRepositories = []

            for author in authors
                promiseOfRepository = q
                    .when fileSystem.list '/var/www/' + author
                    .then (names) ->
                        repositories = []
                        
                        for name in names
                            repository =
                                author: author
                                name: name
                                
                            repositories.push repository
                            
                        return repositories
                
                promisesOfRepositories.push promiseOfRepository
                
            promise = q
                .all promisesOfRepositories
                .then (repositories) ->
                    repositories = _.flatten repositories
                    
                    websites = []
                    
                    for repository in repositories
                        website =
                            repository: repository
                            
                        websites.push website
                    
                    return websites
            
    promiseOfWebsitesWithVersions = q
        .when promiseOfWebsites
        .then (websites) ->
            promisesOfWebsitesWithVersions = []
            
            for website in websites
                promisesOfVersions = [
                    website
                    websitePackage.getVersion website.repository.author, website.repository.name, 'public'
                    websitePackage.getVersion website.repository.author, website.repository.name, 'latest'
                ]

                promiseOfWebsiteWithVersions = q
                    .all promisesOfVersions
                    .spread (website, publicVersion, latestVersion) ->
            
                        website.versions =
                            public: publicVersion
                            latest: latestVersion
                            
                        return website
                            
                promisesOfWebsitesWithVersions.push promiseOfWebsiteWithVersions
                
            promise = q.all promisesOfWebsitesWithVersions
        
    promiseOfEmitting = q
        .when promiseOfWebsitesWithVersions
        .then (websites) ->
            winston.info 'waitress has listed %s websites', websites.length
            socket.emit 'waitress website list', websites
        .catch (error) ->
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
            # todo, return versions and domain request rather than mock it
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

                    winston.info 'waitress has sent %s/%s website request', author, name
                    socket.emit 'waitress website get', website
                .catch (error) ->
                    winston.error 'could not sent %s/%s website request', author, name