_ = require 'lodash'
config = require '../config.json'
Sequelize = require 'sequelize'
sequelize = new Sequelize config.db.database, config.db.username, config.db.password, config.db.options
models = require '../models/'

db = _.chain models
        .map (model, name) ->
                db = {}
                db[name] = sequelize.define name, model
        .map _.extend
        .value()



sequelize.sync().success () ->
        console.log "Database Synchronized at: ", new Date()
module.exports = db
