_ = require 'lodash'
Promise = require "bluebird"
policies = require '../config/policies'

module.exports = (routeActions, req, res) ->
    new Promise (resolve, reject) ->
        require('./getPolicies')()
        
        # This should give us an object of all the policies attached to the controller
        # and action.  To make this a bit more dev-friendly, we'll wrap this in an
        # array, then flatten it.  This way we can make it a nice, linear, one-dimensional
        # list to loop through, and that way you can write an array of policies or just one
        # policy for an action.  If that's what you want. I don't wanna tell you how to live
        # your life.
        .then (actualPolicies) ->
            policyResults = _.flatten _.map routeActions, (action) ->
                    # What I'm doing here is looking for the policies file.
                    # If there is a policy defined for that action, use that, else use the * catch all. 
                    tempPolicies = _.flatten [policies[action.controllerName][action.actionName] || policies[action.controllerName]['*'] ]

                    _.map tempPolicies, (policy) ->
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
            
