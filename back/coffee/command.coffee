# require

winston = require 'winston'

utility = require './utility.coffee'
websiteNginx = require './socket/website/nginx.coffee'

# private

utility.configurations.setLoggingFor winston

testNginxCreation = () ->
    sampleRequest =
        repository:
            author: 'aaa'
            name: 'bbb'

    websiteNginx.create sampleRequest

# execute

do testNginxCreation