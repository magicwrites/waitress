# require

path = require 'path'

configuration = require './../../../../configuration/waitress.json'

# private

# public

exports.getWebsiteNameFrom = (request) ->
    websiteName =
        request.repository.author +
        configuration.characters.separators.website.replaced + 
        request.repository.name
        
exports.getDirectoriesFrom = (request, websiteName) ->
    directories =
        website: configuration.directories.websites + path.sep + websiteName
        stored: configuration.directories.websites + path.sep + websiteName + path.sep + 'stored'
        available: configuration.directories.nginx.available + path.sep
        enabled: configuration.directories.nginx.enabled + path.sep
        
exports.getNginxFilesFrom = (request, websiteName, directories) ->
    files =
        publicFile: directories.available + websiteName + configuration.characters.separators.website.replaced + 'public'
        latestFile: directories.available + websiteName + configuration.characters.separators.website.replaced + 'latest'
        publicLink: directories.enabled + websiteName + configuration.characters.separators.website.replaced + 'public'
        latestLink: directories.enabled + websiteName + configuration.characters.separators.website.replaced + 'latest'
        
exports.getPackageFilesFrom = (request, websiteName, directories) ->
    files =
        public: directories.website + path.sep + 'public' + path.sep + 'package.json'
        latest: directories.website + path.sep + 'latest' + path.sep + 'package.json'