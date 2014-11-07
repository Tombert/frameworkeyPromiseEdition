Promise = require 'bluebird'
fs = Promise.promisifyAll require 'fs'
_ = require 'lodash'
getControllers = require './getControllers'

module.exports = (app) ->
        # This grabs the controllers and returns back a promise'd object of 
        # them. It made more sense to put this in a separate file, since it's
        # arguably useful in its own right. 
        getControllers()

        # Note, do this asynchronously. we'll load the controllers and policies
        # simultaneously.   
        .then (controllerObject) ->
                #Let's load in the routes file
                configuredRoutes = require '../config/routes'

                # Let's loop through the routes file and do the appropriate mapping.
                # NOTE: I really hate that the value comes before the key. 
                _.each configuredRoutes, (totalString, route) -> 
                        # routes are stored like METHOD /route, so we'll split on spaces. 
                        routeComponent = route.split ' '

                        # THe first item should be the method, so we'll grab that.  The toLowerCase
                        # function is there to make the routing a bit more dev friendly in case
                        # they want to use upper-case
                        method = routeComponent[0].toLowerCase()

                        #The second item in that array should be the endpoint. Lets' define a quick
                        # helper-variable. 
                        endpoint = routeComponent[1]

                        # This bigass thing here is for dev-friendliness.  I don't want to punish people
                        # for separating controller calls to multiple lines if they want, and I don't want 
                        # Punish them for adding multiple spaces.  Subsequently, I replace newlines with a 
                        # space, then replace extra spaces down to one space, trim it, and split on the @ 
                        # sign so I can make the dichotomy between application logic and error-handling logic.
                        # Utilizing Coffee's "multi-return" thing, I can set the values pretty cleanly, 
                        # but not before I make sure the values are trimmed. 
                        console.log totalString
                        [actionString, catchString] = totalString
                                                      .replace(/(?:\r\n|\r|\n)/g, ' ')
                                                      .replace( /\s\s+/g, ' ' )
                                                      .trim().split('@')
                                                      .map (i) -> i.trim()

                        #Again, just make it cleaner, we'll utilize the "multi-return" thing coffeescript does. 
                        console.log actionString
                        [catchController,catchFunction] = catchString.split '.' if catchString?
                        

                        # Split the routes on a space so as to separate individual action handlers.
                        allRoutes = actionString.split ' '

                        # Loop through all the actions that are provided for that route,
                        # look them up, return back the handles on the function.
                        #
                        # So as to save a "push" command we'll use a map
                        actionHandles = _.map allRoutes, (a) ->
                                # We want to make it so that there's an option to handle
                                # errors on an individual level.
                                #
                                # We use the questions mark becauae we wanna make it optional
                                # to have an error handler
                                errorStuff = a.split('!')?[1]?.split('.')

                                # We need to parse out the actual funtions being used to handle errors
                                error = controllerObject[errorStuff?[0]]?[errorStuff?[1]]

                                # Since the actinos are written like controller.action, we need to split
                                # on the '.' to separate them. 
                                [myController, myAction] = a.split '.'
                                
                                return {action: controllerObject[myController][myAction], errorHandler: error}

                        wrapper = (req, res) ->

                                        # This is just a quick temporary promise to pass along the req
                                        # and res variables for later. 
                                        tempPromise = new Promise (resolve, reject) ->
                                                resolve req, res

  

                                        # Once we've gotten all the handles on the functions we need
                                        # to call, we can concat it to all previous promises. Afterwards
                                        # we want these to run sequentially, so we use the reduce function
                                        # to run them, then converge into a single, final promise. 
                                        finalPromise =
                                            _.chain [tempPromise]
                                            .concat actionHandles
                                            .reduce (cur, next) ->
                                                cur.then next.action, next.error
                                            .value()

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
                                                        
                                        # We'll use the global catch defined at the end of the actions
                                        # to handle residual errors.  If there's an issue, we go here.
                                        # We can default to an empty function if there's an issue. 
                                        finalPromise.catch controllerObject[catchController]?[catchFunction] || ->

                                                
                        # As stated above, wrapper will return a new function based on what 
                        # we send in for "allRoutes"
                        app[method] endpoint, wrapper
