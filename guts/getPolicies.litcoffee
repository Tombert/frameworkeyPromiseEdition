Grab the Policy Files
=====================
Loop through and grab the policy files. 

    Promise = require 'bluebird'
    _ = require 'lodash'
    fs = Promise.promisifyAll require 'fs'
    module.exports = () ->
        fs.readdirAsync './policies'
        .then (policies) ->
            _.map policies, (policy) ->
                if ((policy.match /.+\.js/g)? or (policy.match /.+\.coffee/g)? or (policy.match /.+\.litcoffee/g)?)
                    myObject = {}
                    name = policy.replace('.js', '').replace('.coffee', '').replace('.litcoffee', '')
                    myObject[name] = require "../policies/#{name}"
                    myObject
        .then (policyArray) ->
            _.reduce policyArray, _.extend
