Promise = require('bluebird')
fs = Promise.promisifyAll require('fs')
_ = require('lodash')


# Grab an array of all the controller files in the controllers folder
#
# Would prefer to make this async.  Will probably convert into a promise soon.
# Can't convert into promise right now as I'm finding it pretty difficult to get
# a handle on module.exports in a nested callback. 
controllers = fs.readdirSync('./controllers/')

#This is a quick object to get a future handle on all the controllers
controllerObject = {}

# We're utilizing the lodash each here as that appears to be faster than the
# built in .forEach function
_.each controllers, (file) ->
        # We're only interested in the files that end with .js or .coffee, so we'll use
        # regex to only grab the ones we need. 
        if file.match(/.+\.js/g) != null || file.match(/.+\.coffee/g) != null
                # When requiring the module, we don't really want to specify an extension.
                # Let's get rid of it. 
                name = file.replace('.js', '').replace('.coffee', '')

                # Require the controller, feed it into the controllers
                controllerObject[name] = require "../controllers/#{name}"
                                           
module.exports = (app) ->

        # Grab the routes from the routes file and load them in to
        # be parsed
        configuredRoutes = require '../config/routes.js'



        for route of configuredRoutes
                # Since routes are of the 'METHOD /route': 'controller.action controller.action2'
                # variety, let's start splitting.
                #
                # First, let's get the method and endpoint by splitting the key on the space. 
                routeComponent = route.split(' ')

                # The toLowerCase serves the purpose of making the router more dev-friendly
                # by allowing them to declare the method in upper-case if they'd like
                #
                # the first item in the routeComponent should be the method, so let's
                # declare a holder-variable to make that more clear. 
                method = routeComponent[0].toLowerCase()

                # The second element should be the endpoint.  The same as above, let's create
                # a holder. 
                endpoint = routeComponent[1]

                # This is basically a glue-function.  We want to utilize the heck out of promises
                # to guarantee proper-flow-control.  Subsequently, we want make sure this inits
                # with the proper promises, and ends with a resolving promise to send the request.
                wrapper = (req, res) ->

                        #Since we can declare multiple actions per route, let's split this on spaces
                        # first. 
                        allRoutes = configuredRoutes[route].split(' ')

                        # We need to store a sequence of promises. It's easier to
                        # guarantee they execute in the right order if you put them in an array. 
                        promiseArray = []

                        # This is just a placeholder promise to make sure that the promise chain
                        # inits properly. 
                        tempPromise = new Promise (resolve, reject) ->
                                resolve("yo")

                        # Push that temp promise to the array to get the action going.         
                        promiseArray.push tempPromise

                        # Let's loop through allRoutes to make sure we execute all the
                        # actions. 
                        _.each allRoutes, (a) ->
                                #We need to separate the controller from teh action. 
                                tempObject = a.split('.')

                                #The first item in the split should be the controller
                                theController = tempObject[0]

                                #The second item should be the action. 
                                theAction = tempObject[1]
                                
                                # We need to lookup and push the contoller action to the array. 
                                promiseArray.push controllerObject[theController][theAction]

                        # Once we're all done, let's wrap it up with a nice, finalizing cleanup array. 
                        endFunction = (finalResult) ->

                                # The last function declared currently needs to have a renderType and data parameter. It's not ideal, but it's the most modular way I could think of.
                                #
                                # We'll determine if you want JSON or HTML based on the renderType declared
                                if finalResult.renderType.toLowerCase() == 'html'
                                        # if the rendertype is HTML, we'll fire off the template
                                        res.render finalResult.page, finalResult.data
                                else if finalResult.renderType.toLowerCase() == 'json'
                                        #If the render type is json, we just need to send a raw
                                        # response back. 
                                        res.send finalResult.data
                        # Push that finalizing function
                        promiseArray.push endFunction

                        # We need to chain all these promises to execute sequentially. The reduce
                        # function is amazingly elegant at that.  It should converge on one final
                        # promise
                        finalPromise = _.reduce promiseArray, (cur, next) ->
                                cur.then(next)
                        # If there are any errors in the sequence, we want to make sure they are
                        # caught, so we make a global catch method. 
                        finalPromise.catch (e) ->
                                console.log "There was an error: #{e}"
                                # If there are any errors, we need to send an error response back. 
                                res.send 500, message: "There was an error"
                app[method](endpoint, wrapper)
