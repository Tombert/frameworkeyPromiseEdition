Grab the Models
===============
This file is for grabbing the model files that sequelize uses.  Since this could be arguably useful in its own right, let's make this its own module. 

##Libraries
    Promise = require 'bluebird'
    _ = require 'lodash'
    fs = Promise.promisifyAll require 'fs'

Note: The `promisifyAll` function is simple a bluebird function that converts callbackey functions in a module, then suffixes them with `Async`

--------------

We need to get a listing of all the model files.

    fs.readdirAsync './models'

Once we've read the files, we can loop through them.  The logic here isn't very complex: we check to make sure that there's a `.js`, `.coffee`, or `.litcoffee` extension, then require it.

    .then (models) ->
        _.map models, (model) ->
            if ((model.match /.+\.js/g)? or (model.match /.+\.coffee/g)? or (model.match /.+\.litcoffee/g)?)
                myObject = {}
                name = model.replace('.js', '').replace('.coffee', '').replace('.litcoffee', '')
                myObject[name] = require "../models/#{name}"
                return myObject

Now that we've gotten all the models in mini-objects in an array, let's merge them into one big object. 

    .then (modelArray) ->
        _.reduce modelArray, _.extend
