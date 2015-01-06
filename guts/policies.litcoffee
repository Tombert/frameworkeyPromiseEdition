Policies
--------
This is the glue-file that manages how user-policies (e.g. who's allowed to do what) get defined.  This file is responsible for grabbing the 

Load in the required libraries

    _ = require 'lodash'
    Promise = require "bluebird"

Load up the user-defined policies. 

    policies = require '../config/policies'


Start the function.  We're expecting an array of objects with the fields `actionName` and `controllerName`, and the node `req` and `res` objects just in case the policies need them.

    module.exports = (routeActions, req, res) ->

We want to reject or resolve the promise based on whether or not someone is allowed to do something.  Therefore, it'd be smart to wrap this in a promise.

        new Promise (resolve, reject) ->

Let's load up the helper function that grabs all the policy files.  This function was arguably useful in its own right, so it made sense to make it its own separate module. 

            require('./getPolicies')()

Once the policies are done loading, we can move on. 

            .then (actualPolicies) ->

Since there is an array routeActions (purposefully), we need to loop through them, and since we need the result afterwards, we can use a map.  Also, since there is a small risk of a couple nested arrays (due to the way that the policies have been implemented, lets flatten it after we're done. 
                
                policyResults = _.flatten _.map routeActions, (action) ->



                    
---------------------------------------


                    
What I'm doing here is looking for the policies file.
If there is a policy defined for that action, use that, else use the `*` catch all.

The flatten is necessary simply because I don't want to punish people for only listing one policy outside of an array.  Subsequently, we'll wrap everything in an array and then flatten it. 

                        tempPolicies = _.flatten [policies[action.controllerName][action.actionName] || policies[action.controllerName]['*'] ]

This is pretty straightforward; we'll loop up the policy in the hash
table and then return back their result (which can just be a true or false

We want to make sure this is properly wrapped in promisey stuff, so we can init
an empty promise then run our stuff in the "then". Since our empty promise only
resolves, it won't hit the catch. 

                        _.map tempPolicies, (policy) ->
                            tempPromise = new Promise (resolve, reject) -> do resolve
                            tempPromise.then -> actualPolicies[policy] req

Once all the policy promises have resolved, let's return out response.
                
                Promise.all policyResults
                .then (results) ->
                    # Not entirely sure I like this logic, but it's pretty straightforward:
                    # I want to allow synchronous or asynchronous policies.  Subsequently, we can
                    # either allow the policy to reject if not permitted or to simply return false. 
                    unless false in results
                      resolve true
                    else
                      reject "Not Authorized"
                
