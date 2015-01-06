Grabbing the Policies
=====================
This file is pretty straightforward: I want to grab all the policies and and return them back so that the permission system can access them when necessary. 

## Libraries

    Promise = require 'bluebird'
    _ = require 'lodash'
    fs = Promise.promisifyAll require 'fs'

As a note, the `promisifyAll` function simply converts all the callbackey functions to "promisey" ones with the `Async` suffix. 


Now that the libraries have been initialized, let's start the function.

    module.exports = () ->

First thing we need to do is get a handle on all the policy files.  

        fs.readdirAsync './policies'

Once we've gotten the policy files, let's bind them to a manageable array.  We'll do this with a pretty straightforward map function, and from there we'll just check to make sure that the the `.js`, `.coffee`, and `.litcoffee` are `require`'d into an object.

        .then (policies) ->
            _.map policies, (policy) ->
                if ((policy.match /.+\.js/g)? or (policy.match /.+\.coffee/g)? or (policy.match /.+\.litcoffee/g)?)
                    myObject = {}

                    # This isn't necessary, but I like doing a require('myModule') instead of
                    # require('myModule.coffee')
                    name = policy.replace('.js', '').replace('.coffee', '').replace('.litcoffee', '')
                    myObject[name] = require "../policies/#{name}"
                    myObject


Now that we have everything in a managable array of objects, we want to put everything into one big hash table.  We can utilize Lodash's reduce function to loop through and converge into one value, then and use the _.extend function to make sure the merging is done properly. 

        .then (policyArray) ->
            _.reduce policyArray, _.extend
