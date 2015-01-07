Parse the form-body
===================

The reasoning for this file is pretty simple: we need to be able to handle more parameters than just `GET` items in the query string.  Subsequently, we're going to utilize the `formidable` package to handle body-parsing and uploads for us. 

##Libraries

    Promise = require 'bluebird'
    _ = require 'lodash'
    formidable = require 'formidable'

Let's start the function.  We're expect a request object, and plan to return back a `Promise` that resolves on the parsed form.

    module.exports = (req) ->

We don't want to parse the form-body if it's just part of the query string, so let's just if-around it.

        if req.method.toLowerCase != 'get'

Let's use Bluebird's promisification so deal a promise instead of a callback.

            form = new formidable.IncomingForm()
            f = Promise.promisifyAll form

Once we've promisified, it becomes as simple as passing in the request object into `formidable`.  This should return back the promise to the parsed body

            f.parseAsync req

This matches up to the `if req.method` above.  Basically, if it makes it into this else, that means we're dealing with a `GET` request, which we don't need to parse, so we'll just send back an empty object.  Since there isn't a lot that can go wrong in simply resolving back an empty object, I don't feel the need to bother with a reject. 

        else
            return new Promise (resolve, reject) -> resolve({})
