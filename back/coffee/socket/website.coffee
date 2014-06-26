# require

winston = require 'winston'
childProcess = require 'child-process-promise'
user = require './user.coffee'
fileSystem = require 'q-io/fs'
q = require 'q'

websiteReader = require './website/reader.coffee'
websiteShell = require './website/shell.coffee'
    
# public

# expose api to publish a website, which:
# copies the entire latest directory to the public one

exports.publish = () ->
    # do it!
    
exports.list = websiteReader.list
exports.get = websiteReader.get

exports.create = websiteShell.create
exports.remove = websiteShell.remove