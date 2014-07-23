express = require 'express'
app = express()

require('./guts/routing')(app)
app.listen(3000)
