express = require 'express'
app = express()

app.set 'views', __dirname + '/views'
app.set 'view engine', 'jade'



require('./guts/routing')(app)
app.listen(3000)
