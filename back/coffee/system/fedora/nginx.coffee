winston = require 'winston'
fileSystem = require 'q-io/fs'
path = require 'path'
q = require 'q'
_ = require 'lodash'

utility = require './../../utility'

configuration = require './../../../../configuration/waitress.json'



exports.install = () ->
#    promiseOfNginx = utility.runShell 'nginx/install.sh'
    
    promiseOfConfigurationFile = q
        .when {} # promiseOfNginx
        .then () ->
            fileSystem.read '/etc/nginx/nginx.conf'
          
    promiseOfAlteredConfiguration = q
        .when promiseOfConfigurationFile
        .then (configurationFile) ->
            configurationFile = configurationFile.replace 'http {', 'http {\n    include /etc/nginx/sites-enabled/*;\n\n'
            
            console.log configurationFile