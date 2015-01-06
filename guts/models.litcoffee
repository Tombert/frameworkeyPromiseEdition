Make the Models
===============

This file is in charge of grabbing the model files, then binding them to sequelize models.

## Libraries.
This will load in the libraries we're using, and load in the right credentials to sequelize.

    _ = require 'lodash'
    Sequelize = require 'sequelize'
    sequelize = new Sequelize config.db.database, config.db.username, config.db.password, config.db.options

Now we should load in the environment configuration. 

    cf = require '../config/config.json'
    config = cf[process.env.NODE_ENV]

## Local Files.
    
    models = require '../models'



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
