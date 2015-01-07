Routing
=======
This file serves as the "glue" between the express router and sanity. Basically, we want a rails-esque routing system with all the routes declared in one location.  One advantage over rails, though, is that we're going to allow some degree of function composition in that we can declare multiple, reusable actions per-route, then let them pass the return value from one to the next.

This is done via unapologetic use of Promises. 

##Libraries

    Promise = require 'bluebird'
    fs = Promise.promisifyAll require 'fs'
    _ = require 'lodash'

As a note, the `Promise.promisifyAll` function simply adds `Async` to the end of the methods in `fs` and subsequently allows Promises to be used instead of callbacks. 

##Local Modules

    getControllers = require './getControllers'
    policies = require './policies'
    bodyParser = require './bodyParser'


Let's kickstart this router.

    module.exports = (app) ->
        
-----------
        
This grabs the controllers and returns back a promise'd object of them. It made more sense to put this in a separate file, since it'sarguably useful in its own right.

        getControllers()

Once we've gotten all the controllers, we'll move on

        .then (controllerObject) ->

Let's load in the routes file

            configuredRoutes = require '../config/routes'

Let's loop through the routes file and do the appropriate mapping.[1]

            _.each configuredRoutes, (totalString, route) ->

                
Routes are stored like METHOD /route, so we'll split on spaces. To make this a bit more dev-friendly, let's get rid of redundant spaces and newlines.

                [method, endpoint] = route
                             .replace /(?:\r\n|\r|\n)/g, ' '
                             .replace /\s\s+/g, ' '
                             .trim()
                             .split ' '

-----------

This bigass thing here is for dev-friendliness.  I don't want to punish people for separating controller calls to multiple lines if they want, and I don't want punish them for adding multiple spaces.  Subsequently, I replace newlines with a  space, then replace extra spaces down to one space, trim it, and split on the @ sign so I can make the dichotomy between application logic and error-handling logic. Utilizing Coffee's "multi-return" thing, I can set the values pretty cleanly, but not before I make sure the values are trimmed.

                [actionString, catchString] = totalString
                                  .replace /(?:\r\n|\r|\n)/g, ' '
                                  .replace /\s\s+/g, ' '
                                  .trim()
                                  .split '@'
                                  .map (i) -> do i.trim
-----------


Again, just make it cleaner, we'll utilize the "multi-return" thing coffeescript does. Since I don't want a hard requirement for a catch to exist, I will put a conditional to see if the catch is defined.

                [catchController,catchFunction] = catchString.split '.' if catchString?

If we have a catch defined, awesome, else we'll just feed in an empty function.
               
                catcher = controllerObject[catchController]?[catchFunction] || ->

Split the routes on a space so as to separate individual action handlers.

                allRoutes = actionString.split ' '

-------

Loop through all the actions that are provided for that route, look them up, return back the handles on the function. So as to save a "push" command we'll use a map

                actionHandles = _.map allRoutes, (a) ->

First we need to separate out the error handling stuff from the actual program, so let's split that out, and utilize the multi-return value feature of coffeescript.

                    [actionStuff, errorStuff] = a.split '!'

Since I don't want to make a hard requirement to provide an error-handler, let's put a put quick "if" at the end of this to make sure we have errorstuff to assign.

                    [errorController, errorAction] = errorStuff.split '.' if errorStuff?

Let's parse out the controller and action.

                    [myController, myAction] = actionStuff.split '.'


Now let's grab the appropriate stuff out of the controllers.

                    finalAction =  controllerObject[myController][myAction]
                    finalError = controllerObject[errorController]?[errorAction]
                    
Since everything is parsed out, let's just wrap this in an object so as to easily pipe into the promises.

                    finalObject =
                        action: finalAction
                        error: finalError
                        controllerName: myController
                        actionName: myAction

Once everything is done, let's just return out of the map and move on. 

                    return finalObject


The `wrapper` function.
-----------------------

This here is the glue that does the joining of the actual functions.  In a nutshell, when the request it made, it should run `wrapper`, which will loop through the functions that were returned by the previous map, and run them sequentially as part of the promise chain.  I would like to eventually add a mechanism in which to do this in parallel (instead of just sequentially) eventually. 

                wrapper = (req, res) ->

We need to make sure the user is allowed to use everything that this route has to offer.  Due to the beauty of Bluebird, if this this trips up, it'll just kill the promise chain and make it so that we don't go any farther than we're allowed to.

                        bodyParser req
                        .then (updatedReq) ->
                            policies actionHandles, updatedReq, res

Once we've gotten all the handles on the functions we need to call, we can concat it to all previous promises. Afterwards we want these to run sequentially, so we use the reduce function to run them, then converge into a single, final promise.

                            finalPromise =
                                _.chain [authPromise, bodyParsePromise]
                                .flatten()
                                .concat actionHandles
                                .reduce (cur, next) ->
                                    cur.then next.action, next.error
                                .value()
                                
Everything should be done.  We can finally render a template or return back JSON depending on what they did on that last function

                            finalPromise.then (endData) ->


What happens now is pretty simple.  A requirement for frameworkey is that you return an object with your data and the `renderType` property. From there it's pretty straightforward.

                                if endData.renderType.toLowerCase() == 'html'
                                    # We used "toLowerCase" to make it more dev-friendly. 
                                    res.render endData.page
                                else if endData.renderType.toLowerCase() == 'json'
                                    res.send endData.data
                                
We'll use the global catch defined at the end of the actions to handle residual errors.  If there's an issue, we go here. We can default to an empty function if there's an issue.

                            finalPromise.catch catcher

                            
As stated above, wrapper will return a new function based on what we send in for "allRoutes".  We're adding the "toLowerCase()" to make this a bit more dev-friendly.

                app[do method.toLowerCase] endpoint, wrapper


[1]: I *really* hate how the value comes before the key in Lodash
