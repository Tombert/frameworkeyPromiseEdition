_ = require 'lodash'
Promise = require "bluebird"
policies = require '../config/policies'

# TODO - write code to grab policies. 
actualPolicies = 

module.exports = (routeActions, req, res) ->
    new Promise (resolve, reject) ->

        # This should give us an object of all the policies attached to the controller
        # and action.  To make this a bit more dev-friendly, we'll wrap this in an
        # array, then flatten it.  This way we can make it a nice, linear, one-dimensional
        # list to loop through.  
        tempActions = _.flatten [ policies[routeActions.controllerName][routeActions.actionName] ]

        policyResults = _.map actions, (policy) ->
                # This is pretty straightforward; we'll loop up the policy in the hash
                # table and then return back their result (which can just be a true or false
                #
                # To make sure the promise runs right, let's write an empty promise that just runs
                actualPolicies[policy] req
    
        # This probably seems a bit weird. One issue I ran into with Bluebird is that it does *not*
        # like doing the promise.all on completely non-promisey arrays.  Since I wanna allow promisey
        # non-promisey code for the policies, it's easiest to just concat an empty promise in the
        # front of the array, to guarantee that we have at least one promise in the array. 
        Promise.all _.concat [new Promise (res) -> res true], policyResults
        .then (results) ->
            # The logic honestly couldn't be a lot simpler here.  Put bluntly,
            # we're just going to have the policies return true or false if they're
            # authorized or not (respectively).  If even one policy says false, we
            # simply tell them to go away. 
            if false not in results
                resolve true
            else
                reject("Not Authorized")
        
