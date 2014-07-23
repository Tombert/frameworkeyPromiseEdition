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
                        myReq = req
                        myRes = res
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


                        endFunction = () ->
                                myRes.send 200, hello: "world"

                        promiseArray.push endFunction
                        _.reduce promiseArray, (cur, next) ->
                                cur.then(next)
                app[method](endpoint, wrapper)
