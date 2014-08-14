Promise = require 'bluebird'
fs = Promise.promisifyAll require 'fs'
_ = require 'lodash'
getControllers = require './getControllers'

module.exports = (app) ->
        getControllers()        
        .then (controllerObject) ->
                #Let's load in the routes file
                configuredRoutes = require '../config/routes'

                # Let's loop through the routes file and do the appropriate mapping.
                for route of configuredRoutes

                        # This is just a handle on the string object so as to avoid square-bracket-hell
                        actionString = configuredRoutes[route]

                        # routes are stored like METHOD /route, so we'll split on spaces. 
                        routeComponent = route.split(' ')

                        # THe first item should be the method, so we'll grab that.  The toLowerCase
                        # function is there to make the routing a bit more dev friendly in case
                        # they want to use upper-case
                        method = routeComponent[0].toLowerCase()

                        #The second item in that array should be the endpoint. Lets' define a quick
                        # helper-variable. 
                        endpoint = routeComponent[1]

                        # I was having a bit of trouble with scopign and not-copying, and since
                        # we're already utilizing lodash, I might as well take advantage of the
                        # deep-copy function they have so as to guarantee it won't be a problem
                        # in the future
                        allRoutes = _.cloneDeep(actionString.split ' ')

                        # This is a thunk'd funciton.  I was having some issues with the "allRoutes"
                        # variable not being the one I needed, and it turns out that it was shallow
                        # and redefining it based on the outside loop.
                        #
                        # Thus, I thunk'd it: I passit it into the function as an argument, so as to
                        # guarantee that I'm getting a personalized "allroutes" variable.  The thunk
                        # then returns a function that we can use. 
                        wrapper = (allRoutes) ->
                                (req, res) ->
                                        # A quick holder for all the promises yet to come. 
                                        promiseArray = []

                                        # This is just a quick temporary promise to pass along the req
                                        # and res variables for later. 
                                        tempPromise = new Promise (resolve, reject) ->
                                                resolve req, res

                                        # Push this promise into our promise array. 
                                        promiseArray.push tempPromise

                                        # Loop through all the actions that are provided for that route,
                                        # look them up, return back the handles on the function.
                                        #
                                        # So as to save a "push" command we'll use a map
                                        actionHandles = _.map allRoutes, (a) ->
                                                actionComponent = a.split '.'
                                                myController = actionComponent[0]
                                                myAction = actionComponent[1]
                                                return controllerObject[myController][myAction]

                                        # Once we've gotten all the handles on the functions we need
                                        # to call, we can concat it to all previous promises. 
                                        endPromiseArray = promiseArray.concat actionHandles

                                        # We need to guarantee these functions will run sequentially,
                                        # piping the output from the previous one to the next one.
                                        #
                                        # It turns out that _.reduce is sort of designed for *exactly that*
                                        #
                                        # This should converge on one final promise. 
                                        finalPromise = _.reduce endPromiseArray, (cur, next) ->
                                                cur.then(next)

                                        # Everything should be done.  We can finally render a template
                                        # or return back JSON depending on what they did on that last function
                                        finalPromise.then (endData) ->

                                                # If they want HTML, we'll give them HTML, gosh-darnit!
                                                #
                                                # We're using toLowerCase to make it a bit more dev-friendly
                                                # in case they want to write html as HTML for some reason
                                                if endData.renderType.toLowerCase() == 'html'
                                                        # End the request by rendering the jade template
                                                        res.render endData.page
                                                        
                                                # If they're making an API, let them make an api. 
                                                else if endData.renderType.toLowerCase() == 'json'
                                                        # end the request by sending back a status JSON
                                                        res.send endData.data

                                        finalPromise.catch (e) ->
                                                # if there was an error anywhere along the way, let's
                                                # end the chain, and throw back a 500 error. Let's
                                                # log that error.
                                                console.log "There has been an error: #{e}"
                                                res.send 500, message: 'There has been an error'
                                                
                        # As stated above, wrapper will return a new function based on what 
                        # we send in for "allRoutes"
                        app[method](endpoint, wrapper(allRoutes))
