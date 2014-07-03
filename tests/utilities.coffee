# require

q = require 'q'

# public

exports.wrapInPromise = (something) ->
    deferred = q.defer()
    deferred.resolve something
    deferred.promise