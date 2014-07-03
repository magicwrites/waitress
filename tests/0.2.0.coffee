# require 

sinon = require 'sinon'
winston = require 'winston'

user = require './../back-refactored/coffee/server/user'
utilities = require './utilities'

# execute

describe '0.2.0', () ->
    
    before () ->
        sinon.stub winston, 'info'
        sinon.stub winston, 'warn'
        sinon.stub winston, 'error'
    
    describe 'User interaction', () ->
    
        require './user/create'
        require './user/is-authorized'
        require './user/is-created'
    
    describe 'Authorized requests', () ->
        before () ->
            sinon.stub user, 'isAuthorized', () ->
                utilities.wrapInPromise yes
                
        after () ->
            user.isAuthorized.restore()
    
        describe 'Website interaction', () ->
            require './website/list'