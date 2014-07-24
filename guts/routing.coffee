Promise = require('bluebird')
fs = Promise.promisifyAll require('fs')
_ = require('lodash')


# Grab an array of all the controller files in the controllers folder
#
# @future
# Would prefer to make this async.  Will probably convert into a promise soon.
# Can't convert into promise right now as I'm finding it pretty difficult to get
# a handle on module.exports in a nested callback. 
controllers = fs.readdirAsync('./controllers/')


module.exports = (app) ->
        controllerObject = {}
        fs.readdirAsync('./controllers/').then (controllers) ->
                #This is a quick object to get a future handle on all the controllers


                makeAsyncControllerParse = (file) ->
                        return new Promise (resolve, reject) ->
                                if file.match(/.+\.js/g) != null || file.match(/.+\.coffee/g) != null
                                        # When requiring the module, we don't really want to specify an extension.
                                        # Let's get rid of it. 
                                        name = file.replace('.js', '').replace('.coffee', '')

                                        # Require the controller, feed it into the controllers
                                        controllerObject[name] = require "../controllers/#{name}"
                                        resolve()
                listOfPromises = _.map controllers, makeAsyncControllerParse

                return Promise.all listOfPromises
        .then () ->
                configuredRoutes = require '../config/routes'                
                for route of configuredRoutes
                        actionString = configuredRoutes[route]
                        routeComponent = route.split(' ')
                        method = routeComponent[0].toLowerCase()
                        endpoint = routeComponent[1]
                        allRoutes = _.cloneDeep(actionString.split ' ')
                        wrapper = (allRoutes) ->
                                (req, res) ->

                                        console.log allRoutes
            
                                        promiseArray = []
                                        tempPromise = new Promise (resolve, reject) ->
                                                resolve req, res
                                        promiseArray.push tempPromise
                                        actionHandles = _.map allRoutes, (a) ->
                                                actionComponent = a.split '.'
                                                myController = actionComponent[0]
                                                myAction = actionComponent[1]
                                                return controllerObject[myController][myAction]
                                        endPromiseArray = promiseArray.concat actionHandles
                                        finalPromise = _.reduce endPromiseArray, (cur, next) ->
                                                cur.then(next)

                                        finalPromise.then (endData) ->
                                                console.log 'This is a test'
                                                if endData.renderType.toLowerCase() == 'html'
                                                        res.render endData.page
                                                else if endData.renderType.toLowerCase() == 'json'
                                                        res.send endData.data

                        console.log method
                        console.log endpoint
                        app[method](endpoint, wrapper(allRoutes))
