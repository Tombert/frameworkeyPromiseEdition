_ = require 'lodash'
cf = require '../config/config.json'

config = cf[process.env.NODE_ENV]

Sequelize = require 'sequelize'
sequelize = new Sequelize config.db.database, config.db.username, config.db.password, config.db.options
models = require '../models/'

module.exports = () ->
    # Let's loop through and create the database. 
    db =
        _.chain models
        .map (model, name) ->

            # We need a handle on the database objects,
            # so lets bind them to a temp object
            db = {}
            db[name] = sequelize.define name, model

            # After we're done, let's return the object
            db

        # Now that we have a bunch of random objects in an array,
        # let's concat them into on big databse object. 
        .reduce _.extend
        .value()

    # Now that we've created all these DB relations, let's 
    sequelize.sync().success -> console.log "Database Synchronized at: ", new Date()

    return db
