# require

assert = require 'assert'
sinon = require 'sinon'
q = require 'q'
_ = require 'lodash'
fileSystem = require 'q-io/fs'
childProcess = require 'child-process-promise'

utilities = require '../utilities.coffee'
configuration = require '../../configuration/waitress'
website = require '../../back-refactored/coffee/server/website.coffee'
websiteNginx = require '../../back-refactored/coffee/server/website/nginx.coffee'

# private

requests =
    valid:
        user:
            username: 'some-user'
            password: 'some-hashed-password'
        data:
            repository:
                author: 'some-repository-user'
                name: 'some-repository-name'
                
# execute

xdescribe 'I EXPECT a way to improve my deploy experience with simple websites and tools', () ->
    
    describe 'WHEN I will send a website creation request', () ->
        response = null
        spies = {}
        
        before (done) ->
            spies.fileSystemMakeTree = sinon.stub fileSystem, 'makeTree', () ->
                utilities.wrapInPromise yes
            spies.childProcessSpawn = sinon.stub childProcess, 'spawn', () ->
                utilities.wrapInPromise yes
            spies.websiteNginxSpawn = sinon.stub websiteNginx, 'create', () ->
                utilities.wrapInPromise yes
    
            promise = website.create requests.valid
            promise.then (data) ->
                response = data
                done()

        after () ->
            fileSystem.makeTree.restore()
                
        it 'SHOULD create website diretories', () ->
            spies.websiteFilesCreate.called
            
        it 'SHOULD check out latest repository', () ->
            spies.websiteGithubPull.calledWith requests.valid
            
        it 'SHOULD result in nginx exposure for both public and latest environments', () ->
            spies.websiteNginxCreate.calledWith requests.valid
            
        it 'SHOULD result in automatic pulling of the newest repository version', () ->
            spies.websiteGithubListen.calledWith requests.valid