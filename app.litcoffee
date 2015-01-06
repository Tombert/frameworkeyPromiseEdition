Kickstart File
--------------
This file is responsible for starting up the entire server. 

Lets start by initializing our basic express stuff.

    express = require 'express'
    app = express()


We need to set a default "views" directory. "/views" makes sense.

    app.set 'views', __dirname + '/views'

Right now, jade templates are the default.

    app.set 'view engine', 'jade'

Let's set the /public directory to be the only public directory for assets

    app.use(express.static(__dirname + '/public'))

This is our route-mapper

    require('./guts/routing')(app)

We will listen on the port 3000.

    app.listen(3000)
