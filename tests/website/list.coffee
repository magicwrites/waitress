# require

assert = require 'assert'
sinon = require 'sinon'
q = require 'q'
_ = require 'lodash'
fileSystem = require 'q-io/fs'

utilities = require '../utilities.coffee'
configuration = require '../../configuration/waitress'
website = require '../../back-refactored/coffee/server/website.coffee'
user = require '../../back-refactored/coffee/server/user.coffee'

# private

requests =
    valid:
        user:
            username: 'some-user'
            password: 'some-hashed-password'
            
stubs =
    directories:
        websites: [
            ['someauthor', 'somewebsite'].join configuration.characters.separators.website.replaced
            ['someauthor', 'anotherwebsite'].join configuration.characters.separators.website.replaced
            ['otherauthor', 'yetanotherwebsite'].join configuration.characters.separators.website.replaced
        ]

responses =
    valid: [
        ['someauthor', 'somewebsite'].join configuration.characters.separators.website.replacer
        ['someauthor', 'anotherwebsite'].join configuration.characters.separators.website.replacer
        ['otherauthor', 'yetanotherwebsite'].join configuration.characters.separators.website.replacer
    ]

# execute

describe 'I EXPECT an ability to list websites that are controlled by a waitress', () ->
    
    describe 'WHEN I will send a request', () ->
        response = null
        stub = null
        spy = null

        before (done) ->
            stub = sinon.stub fileSystem, 'list'
            
            spy = stub
                .withArgs configuration.directories.websites
                .returns stubs.directories.websites

            promise = website.list requests.valid
            promise.then (data) ->
                response = data
                done()

        after () ->
            fileSystem.list.restore()

        it 'SHOULD attempt to list directories that contains websites', () ->
            assert spy.called 

        it 'SHOULD return a list of directories that store websites', () ->
            assert _.isEqual response, responses.valid