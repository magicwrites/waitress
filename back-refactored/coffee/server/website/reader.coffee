# require

winston = require 'winston'
q = require 'q'
fileSystem = require 'q-io/fs'
_ = require 'lodash'

configuration = require './../../../../configuration/waitress.json'

# public

exports.list = () ->
    winston.info 'listing available websites'
    
    promiseOfListing = q
        .when fileSystem.list configuration.directories.websites
        .then (list) ->
            listing = []
            
            for element in list
                replaced = configuration.characters.separators.website.replaced
                replacer = configuration.characters.separators.website.replacer
                
                listing.push element.replace replaced, replacer
                
            return listing
        .catch (error) ->
            winston.error 'could not list websites: %s', JSON.stringify error, null, 4
            
            
            
exports.get = () ->
    #