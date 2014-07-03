## require
#
#assert = require 'assert'
#sinon = require 'sinon'
#q = require 'q'
#_ = require 'lodash'
#fileSystem = require 'q-io/fs'
#
#utilities = require '../utilities.coffee'
#configuration = require '../../configuration/waitress'
#website = require '../../back-refactored/coffee/server/website.coffee'
#
## private
#
#stubs =
#    winston: utilities.stubWinston()
#    authorization: utilities.stubAuthorization()
#
#requests =
#    valid:
#        user:
#            username: 'some-user'
#            password: 'some-hashed-password'
#        data:
#            repository:
#                author: 'some-repository-user'
#                name: 'some-repository-name'
#
## execute
#
#describe 'I EXPECT an ability to list websites that are controlled by a waitress', () ->
#    utilities.unstub()
#    
#    describe 'WHEN I will send a request', () ->
#        response = null
#
#        before (done) ->
#            promise = website.list requests.valid
#            promise.then (data) ->
#                response = data
#                done()
#
#        it 'SHOULD attempt to list directories that contains websites', () ->
#            assert spy.called 
#
#        it 'SHOULD return a list of directories that store websites', () ->
#            assert _.isEqual response, responses.valid
#
#        after () ->
#            fileSystem.list.restore()