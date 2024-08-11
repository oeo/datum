# vim: set expandtab tabstop=2 shiftwidth=2 softtabstop=2
{ env, exit } = process
{ log, L } = require './logger'
{ emit } = require './emitter'

_ = require 'lodash'

mongoose = require 'mongoose'
IORedis = require 'ioredis'

# Redis options
redisOptions = {
  host: env.REDIS_HOST or '127.0.0.1'
  port: env.REDIS_PORT or 6379
  password: env.REDIS_PASSWORD
  db: env.REDIS_DB_INDEX or 0
}

connections = {
  redis: 0
  mongo: 0
}

# mongo
mongoose.connect env.MONGODB_URI
  .catch (error) -> L.error error
  .then ->
    connections.mongo = true
    L 'connected to mongo'
  .catch (error) -> L.error error

# redis
redis = new IORedis(redisOptions)
  .on 'error', (error) -> L.error error
  .on 'connect', ->
    connections.redis = true
    L 'connected to redis'

# ready promise
connected = ready = ->
  new Promise (resolve, reject) ->
    check = ->
      if _.sum(_.values(connections)) is _.size(connections)
        resolve()
        clearInterval _check

    _check = setInterval check, 1
    check()

module.exports = {
  mongoose
  redis
  connected
  ready
}

