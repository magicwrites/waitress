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

# execute

describe 'I EXPECT an ability to define user sign-in credentials if those are not yet present', () ->
    
    describe 'WHEN I will send a request with valid user credentials', () ->
        response = null
        stub = null
        
        before (done) ->
            stub = sinon.stub fileSystem, 'write'
            
            promise = user.create requests.valid
            promise.then (data) ->
                response = data
                done()
        
        it 'SHOULD create a new file with this credentials', () ->
            assert stub.called 
        
        it 'SHOULD respond with the same user credentials as a confirmation', () ->
            assert response is requests.valid.user
                
        after () ->
            fileSystem.write.restore()
            
    describe 'WHEN the request is invalid', () ->
        
        it 'SHOULD not perform any error handling', (done) ->
            done()