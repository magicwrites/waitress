# require

path = require 'path'

configuration = require './../../../../configuration/waitress.json'

# public

exports.getDirectoryFrom = (author, name) ->
    repositoryDirectory =
        configuration.directories.repositories +
        path.sep +
        author +
        configuration.characters.separators.repository.replaced +
        name