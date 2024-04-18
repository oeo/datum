// vim: set expandtab tabstop=2 shiftwidth=2 softtabstop=2
process.env.ENV_SET = 1

require('dotenv').config({
  path: process.env.NODE_ENV === 'production' ? './.env.production' : './.env'
})

require('coffeescript/register')
module.exports.handler = require('serverless-http')(require('./app.coffee'))

