mongoose = require 'mongoose'
q = require 'q'
winston = require 'winston'

configuration = require './../../configuration/waitress.json'
utility = require './utility'



exports.Setting = mongoose.model 'Setting',
    host: { type: String, default: 'localhost' }

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
    
exports.Domain = mongoose.model 'Domain',
    name: { type: String }
    repository: { type: mongoose.Schema.Types.ObjectId, ref: 'Repository' }
    
exports.Log = mongoose.model 'Log', new mongoose.Schema {},
    capped: { size: 8388608 } # more or less 2MB



exports.mongoose = mongoose

exports.connect = () ->
    winston.info 'connecting to the database %s', configuration.database.string
    
    deferred = q.defer()
    
    mongoose.connect configuration.database.string, (error) ->
        if  error
            winston.error 'could not connect to the database: %s', error.message
            deferred.reject error
        else
            winston.info 'successfuly connected to the database %s', configuration.database.string
            deferred.resolve mongoose
            utility.setDatabaseLoggingFor winston
            
    deferred.promise