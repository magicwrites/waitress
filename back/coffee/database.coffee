mongoose = require 'mongoose'
q = require 'q'
winston = require 'winston'
configuration = require './../../configuration/waitress.json'



exports.mongoose = mongoose

exports.connect = () ->
    winston.info 'connecting to the database %s', configuration.database.string
    
    deferred = q.defer()
    
    mongoose.connect configuration.database.string, (error) ->
        if error
            winston.error 'could not connect to the database: %s', error.message
            deferred.reject error
        else
            winston.info 'successfuly connected to the database %s', configuration.database.string
            deferred.resolve mongoose
            
    deferred.promise



exports.User = mongoose.model 'User',
    name: { type: String }
    password: { type: String }
    
exports.Github = mongoose.model 'Github',
    username: { type: String }
    password: { type: String }

exports.Repository = mongoose.model 'Repository',
    author: { type: String }
    name: { type: String }
    dateOfLatestPulling: { type: Date, default: Date.now }
    dateOfLatestPublishing: { type: Date, default: Date.now }

exports.Reservation = mongoose.model 'Reservation',
    port: { type: Number, min: 2500, max: 9000, unique: yes }
    role: { type: String, enum: [ 'public', 'latest', 'github' ] }
    repository: { type: mongoose.Schema.Types.ObjectId, ref: 'Repository' }