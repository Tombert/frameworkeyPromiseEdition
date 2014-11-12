Promise = require 'bluebird'
fs = Promise.promisifyAll require 'fs'
_ = require 'lodash'

module.exports = () ->
        
        # For performance reasons, we'll do this asynchronously. 
        fs.readdirAsync('./controllers/').then (controllers) ->

                #This probably isn't necessary: I wanted to parse through and grab all these controllers
                # asynchronously, so I threw them in a promise
                makeAsyncControllerParse = (file) ->
                        return new Promise (resolve, reject) ->
                                if file.match(/.+\.js/g) != null || file.match(/.+\.coffee/g) != null
                                        # When requiring the module, we don't really want to specify an extension.
                                        # Let's get rid of it.
                                        myObject = {}
                                        name = file.replace('.js', '').replace('.coffee', '')

                                        # Require the controller, feed it into the controllers
                                        myObject[name] = require "../controllers/#{name}"
                                        resolve(myObject)

                # Create a big ol' object of all the promises so that we have a handle on all the files.
                #
                # We're utilizing lodash's "chain" function simply because it gives us somewhat sane list
                # comprehension comparable to linq. 
                promiseObject =
                        do
                                _.chain controllers
                                .map makeAsyncControllerParse
                                .reduce _.extend
                                .value

                # Once everything is done from above, we return back the collective promise object and
                # pipe that to whomever feels fit. 
                return Promise.props promiseObject
