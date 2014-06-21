# require

moment = require 'moment'

# private

getNiceTimestamp = () ->
    '[ ' + new moment().format 'YYYY-MM-DD HH:mm:ss' + ' ]'

constants =
    configurations:
        winston:
            console:
                colorize: yes
                timestamp: getNiceTimestamp
            file:
                colorize: yes
                timestamp: getNiceTimestamp
                filename: './../logs/back.json'
    events:
        delimiter: ':'

# public
        
exports.configurations =
    setLoggingFor: (winston) ->
        winston.remove winston.transports.Console
        winston.add winston.transports.Console, constants.configurations.winston.console
        winston.add winston.transports.File, constants.configurations.winston.file

exports.events =
    getNameFrom: (moduleName, actionName) ->
        nameParts = []
        nameParts.push 'waitress'
        nameParts.push moduleName

        if actionName then nameParts.push actionName

        eventName = nameParts.join constants.events.delimiter