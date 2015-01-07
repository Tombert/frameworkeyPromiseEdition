Grab the Files
=====================
I found that I we reusing a lot of the same logic to get the policies, controllers, and models, when in reality it is pretty trivial to reuse and just have a parameter. 

    Promise = require 'bluebird'
    _ = require 'lodash'
    fs = Promise.promisifyAll require 'fs'
    module.exports = (type) ->
        fs.readdirAsync './#{type}'
        .then (files) ->
            _.map files, (file) ->
                if ((file.match /.+\.js/g)? or (file.match /.+\.coffee/g)? or (file.match /.+\.litcoffee/g)?)
                    myObject = {}
                    name = file.replace('.js', '').replace('.coffee', '').replace('.litcoffee', '')
                    myObject[name] = require "../#{type}/#{name}"
                    myObject
        .then (fileArray) ->
            _.reduce fileArray, _.extend
