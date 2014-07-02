# require

io = require 'socket.io-client'
assert = require 'assert'
sinon = require 'sinon'
q = require 'q'
fileSystem = require 'q-io/fs'

# private

user = require '../../back-refactored/coffee/server/user.coffee'

# execute

describe 'I EXPECT to be able to determine whether user account is already created', () ->

    describe 'WHEN it was', () ->
        isCreated = null
        fileSystemExists = null

        before (done) ->
            fileSystemExists = sinon.stub fileSystem, 'exists', () ->
                deferred = q.defer()
                deferred.resolve yes
                deferred.promise
            
            promise = user.isCreated()
            promise.then (response) ->
                isCreated = response
                done()
                
        after () ->
            fileSystem.exists.restore()

        it 'SHOULD check whether file with credentials exists', () ->
            assert fileSystemExists.called
            
        it 'SHOULD confirm that it does', () ->
            assert isCreated is yes

    describe 'WHEN it was not', () ->
        isCreated = null
        fileSystemExists = null

        before (done) ->
            fileSystemExists = sinon.stub fileSystem, 'exists', () ->
                deferred = q.defer()
                deferred.resolve no
                deferred.promise
            
            promise = user.isCreated()
            promise.then (response) ->
                isCreated = response
                done()
                
        after () ->
            fileSystem.exists.restore()

        it 'SHOULD check whether file with credentials exists', () ->
            assert fileSystemExists.called
            
        it 'SHOULD confirm that it does not', () ->
            assert isCreated isnt yes