// vim: set expandtab tabstop=2 shiftwidth=2 softtabstop=2
process.env.ENV_SET = 1

require('dotenv').config({
  path: (function() {
    if (process.env.NODE_ENV === 'production') {
      return __dirname + '/.env.production';
    }
    if (process.env.NODE_ENV === 'staging') {
      return __dirname + '/.env.staging';
    } else {
      process.env.NODE_ENV = 'local'
      return __dirname + '/.env'
    }
  })()
})

require('coffeescript/register')
module.exports.handler = require('serverless-http')(require('./app.coffee'))

