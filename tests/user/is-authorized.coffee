# require

assert = require 'assert'
sinon = require 'sinon'
q = require 'q'
fileSystem = require 'q-io/fs'

utilities = require '../utilities.coffee'
configuration = require '../../configuration/waitress'
user = require '../../back-refactored/coffee/server/user.coffee'

# private

stubs =
    winston: utilities.stubWinston()

requests =
    valid:
        user:
            username: 'some-user'
            password: 'some-hashed-password'
        data:
            some: 'data'
    invalid:
        user:
            username: 'some-user'
            password: 'some-wrong-password'
        data:
            some: 'data'
    
# execute

describe 'I EXPECT a way to authorize my requests with user credentials', () ->

    describe 'WHEN my request credentials are valid', () ->
        response = null
        stub = null
        spy = null
        
        before (done) ->
            stub = sinon.stub fileSystem, 'read'

            spy = stub
                .withArgs configuration.files.user.json
                .returns utilities.wrapInPromise JSON.stringify requests.valid.user, null, 4
            
            promise = user.isAuthorized requests.valid
            promise.then (data) ->
                response = data
                done()

        it 'SHOULD use the stored file during the process', () ->
            assert stub.called
            
        it 'SHOULD confirm the authorization', () ->
            assert response is yes
                
        after () ->
            fileSystem.read.restore()

    describe 'WHEN my request credentials are not valid', () ->
        response = null
        stub = null
        spy = null
        
        before (done) ->
            stub = sinon.stub fileSystem, 'read'

            spy = stub
                .withArgs configuration.files.user.json
                .returns utilities.wrapInPromise JSON.stringify requests.valid.user, null, 4

            promise = user.isAuthorized requests.invalid
            promise.then (data) ->
                response = data
                done()

        it 'SHOULD use the stored file during the process', () ->
            assert stub.called
            
        it 'SHOULD reject the authorization', () ->
            assert response is no
                
        after () ->
            fileSystem.read.restore()