# require

q = require 'q'
winston = require 'winston'
sinon = require 'sinon'

user = require '../back-refactored/coffee/server/user.coffee'

# private

winstonStubs = null

# public

exports.stubWinston = () ->
#    if winstonStubs
#        winstonStubs.info.restore()
#        winstonStubs.warn.restore()
#        winstonStubs.error.restore()
#    
#    winstonStubs =
#        info: sinon.stub winston, 'info'
#        warn: sinon.stub winston, 'warn'
#        error: sinon.stub winston, 'error'

exports.wrapInPromise = (something) ->
    deferred = q.defer()
    deferred.resolve something
    deferred.promise