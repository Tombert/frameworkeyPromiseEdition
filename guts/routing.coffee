Promise = require('bluebird')
fs = Promise.promisifyAll require('fs')
_ = require('lodash')

fs.readdirAsync('../controller/').then (controllers) ->
        _.map controllers, (file) ->
                if (file.match(/.+\.js/g) !== null || if (file.match(/.+\.coffee/g) !== null
                        name = file.replace('.js', '').replace('.coffee', '')
                        controllerObject[name] = require "../controllers/#{name}"
                                           
module.exports = (app) ->
configuredRoutes = require '../config/routes.js'



for route of configuredRoutes

        routeComponents = route.split(' ')
        method = routeComponent[0].toLowerCase()
        endpoint = routeComponent[1]
        wrapper = () ->
                
        app[method](endPoint, wrapper)
