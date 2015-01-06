Grab the Controllers
====================

##Libraries
 
    Promise = require 'bluebird'
    fs = Promise.promisifyAll require 'fs'
    _ = require 'lodash'

Note: The `promisifyAll` function simply takes a module, takes all the callbackey functions from that module, and converts them to "promisey" versions with the `Async` name as a suffix.

----------

Let's start the function.

    module.exports = () ->
        
Let's load all the files in the controllers directory.

        fs.readdirAsync './controllers'

        .then (controllers) ->

Now that we've gotten a handle on the controller files, let's write a helper function to parse out controllers and bind to an object

This function is pretty straightforward: look at a file, see if it is a `js` or `coffee` file, then `require` accordingly.  From there we can `resolve` on an object.

            makeAsyncControllerParse = (file) ->
                return new Promise (resolve, reject) ->
                    if ((file.match /.+\.js/g)? or (file.match /.+\.coffee/g)? or (file.match /.+\.litcoffee/g)?)

                        myObject = {}
                        name = file.replace('.js', '').replace('.coffee', '').replace('.litcoffee', '')
                        myObject[name] = require "../controllers/#{name}"
                        resolve myObject


Now that we've defined our helper function, we can map through the controllers, then grab back the array of objects. we can utilize lodash's `extend` function to make a huge object out of it.

            promiseObject =
                do
                    _.chain controllers
                    .map makeAsyncControllerParse
                    .reduce (bigObject, smallObject) -> _.extend bigObject, smallObject
                    .value
Once everything is done from above, we return back the collective promise object and pipe that to whomever feels fit.

            return Promise.props promiseObject
