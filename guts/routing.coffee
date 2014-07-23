Promise = require('bluebird')
fs = Promise.promisifyAll require('fs')
_ = require('lodash')



controllers = fs.readdirSync('./controllers/')
controllerObject = {}
_.map controllers, (file) ->
        if file.match(/.+\.js/g) != null || file.match(/.+\.coffee/g) != null
                name = file.replace('.js', '').replace('.coffee', '')
                controllerObject[name] = require "../controllers/#{name}"
                                           
module.exports = (app) ->
        configuredRoutes = require '../config/routes.js'



        for route of configuredRoutes

                routeComponent = route.split(' ')
                method = routeComponent[0].toLowerCase()
                endpoint = routeComponent[1]
                wrapper = (req, res) ->
                        allRoutes = configuredRoutes[route].split(' ')
                        promiseArray = []

                        tempPromise = new Promise (resolve, reject) ->
                                resolve("yo")
                        promiseArray.push tempPromise
                        console.log allRoutes
                        _.each allRoutes, (a) ->
                                tempObject = a.split('.')
                                theController = tempObject[0]
                                theAction = tempObject[1]
                                console.log "\n\n\n\n\n\n",theController
                                promiseArray.push controllerObject[theController][theAction]


                        endFunction = (finalResult) ->
                                console.log finalResult
                                if finalResult.renderType.toLowerCase() == 'html'
                                        res.render finalResult.page, finalResult.data
                                else if finalResult.renderType.toLowerCase() == 'json'
                                        res.send finalResult.data

                        promiseArray.push endFunction
                        finalPromise = _.reduce promiseArray, (cur, next) ->
                                cur.then(next)
                                
                        finalPromise.catch (e) ->
                                console.log "There was an error: #{e}"
                                res.send 500, message: "There was an error"
                app[method](endpoint, wrapper)
