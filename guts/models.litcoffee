Make the Models
===============

This file is in charge of grabbing the model files, then binding them to Sequelize models.

## Libraries.

This will load in the libraries we're using, and load in the right credentials to sequelize.

    _ = require 'lodash'
    Sequelize = require 'sequelize'
    sequelize = new Sequelize config.db.database, config.db.username, config.db.password, config.db.options

Now we should load in the environment configuration. 

    cf = require '../config/config.json'
    config = cf[process.env.NODE_ENV]

Let's start the function.

    module.exports = () ->
        
-------------

First we need to grab all the model files
 
        require('./getFiles')('models')

Once we have a handle on the models, we can proceeed to process them. We'll just map through the models, and concatinate them into one big object of Sequelize objects using a combination of the `reduce` and `extend` function from lodash. 

        .then (models) ->            
            db =
                _.chain models
                .map (model, name) ->
                    db = {}
                    db[name] = sequelize.define name, model
                    db
                .reduce _.extend
                .value()



Now that we've created a bunch of sequelize models, let's make sure that the database is synchronized.  If there's any issues, we'll log it out.  Otherwise, we'll just print a message that everything is sync'd.


            sequelize.sync().success -> console.log "Database Synchronized at: ", new Date()
                .error (e) -> console.log e


Let's just return a handle on the database.


            return db
