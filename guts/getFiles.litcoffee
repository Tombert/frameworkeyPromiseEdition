Grab the Files
=====================
I found that I we reusing a lot of the same logic to get the policies, controllers, and models, when in reality it is pretty trivial to reuse and just have a parameter. 

## Libraries

    Promise = require 'bluebird'
    _ = require 'lodash'
    fs = Promise.promisifyAll require 'fs'

Note: The `promisifyAll` function simply takes a module, suffixes the functions with the word `Async`, and makes them promisable instead of callbackey.

----------

Let's start the function. Expected input is a string of the type of file you want, and the expected output is a promise'd array of objects of the imported files. 

    module.exports = (type) ->

Let's read in the folder of the files. 

        fs.readdirAsync './#{type}'

Once the files have been loaded, the remaining logic is pretty simple: We `map` through them and require them, and from there we can plop them into an array.

        .then (files) ->
            _.map files, (file) ->
                if ((file.match /.+\.js/g)? or (file.match /.+\.coffee/g)? or (file.match /.+\.litcoffee/g)?)
                    myObject = {}
                    name = file.replace('.js', '').replace('.coffee', '').replace('.litcoffee', '')
                    myObject[name] = require "../#{type}/#{name}"
                    myObject

Once we've put all these files into an array, we'd like to merge them into one big object.  We can utilize lodash's reduce function to handle returning back one item, and we can use lodash's extend function to handle the merging. 

        .then (fileArray) ->
            _.reduce fileArray, _.extend
