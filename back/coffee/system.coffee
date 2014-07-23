winston = require 'winston'
q = require 'q'

configuration = require './../../configuration/waitress.json'
utility = require './utility'

nginx = require './system/fedora/nginx'



do () ->
    utility.setLoggingFor winston
    
    winston.info 'setting up waitress fedora environment'
    
    nginx.install()