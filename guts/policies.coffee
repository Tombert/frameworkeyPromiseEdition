_ = require 'lodash'
Promise = require "bluebird"
policies = require '../config/policies'

# TODO - write code to grab policies. 
actualPolicies = {}

module.exports = (routeActions, req, res) ->
    new Promise (resolve, reject) ->

        # This should give us an object of all the policies attached to the controller
        # and action.  To make this a bit more dev-friendly, we'll wrap this in an
        # array, then flatten it.  This way we can make it a nice, linear, one-dimensional
        # list to loop through, and that way you can write an array of policies or just one
        # policy for an action.  If that's what you want. I don't wanna tell you how to live
        # your life. 
        tempActions = _.flatten [ policies[routeActions.controllerName][routeActions.actionName] ]

        policyResults = _.map actions, (policy) ->
                # This is pretty straightforward; we'll loop up the policy in the hash
                # table and then return back their result (which can just be a true or false
                #
                # We want to make sure this is properly wrapped in promisey stuff, so we can init
                # an empty promise then run our stuff in the "then". Since our empty promise only
                # resolves, it won't hit the catch. 
                tempPromise = new Promise (resolve, reject) -> do resolve
                tempPromise.then -> actualPolicies[policy] req
    
        Promise.all policyResults
        .then (results) ->
            # Not entirely sure I like this logic, but it's pretty straightforward:
            # I want to allow synchronous or asynchronous policies.  Subsequently, we can
            # either allow the policy to reject if not permitted or to simply return false. 
            unless false in results
              resolve true
            else
              reject "Not Authorized"
            
