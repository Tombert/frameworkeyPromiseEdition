Kickstart File
--------------
This file is responsible for starting up the entire server. 

Let's start by initializing our basic express stuff.

    express = require 'express'
    app = express()

Let's also load in the config
    config = require('./config/config')[process.env.NODE_ENV]

We need to set a default "views" directory. `/views` makes sense.

    app.set 'views', __dirname + '/views'

Right now, jade templates are the default.

    app.set 'view engine', 'jade'

Let's set the `/public` directory to be the only public directory for assets

    app.use(express.static(__dirname + '/public'))

This is our route-mapper, which is responsible for acting as "glue" between the routes and the controllers. 

    require('./guts/routing')(app)

We will listen on the port specified in the environment variable or fall back to  `3000` if nothing is set. 

    app.listen(config.port || 3000)
