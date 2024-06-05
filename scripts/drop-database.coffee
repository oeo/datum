# vim: set expandtab tabstop=2 shiftwidth=2 softtabstop=2
{ log, L } = require './../lib/logger'
{ exit, env } = process

require './../lib/env'

{ mongoose, redis, connected } = require './../lib/database'

helpers = require './../lib/helpers'

_ = require 'lodash'

run = ->
  await connected()

  start = new Date

  for modelName, _model of (require './../models')
    try
      collections = await mongoose.connection.db.listCollections().toArray()
      if collections.some((col) -> col.name == _model.collection.collectionName)
        L 'dropping collection', modelName
        await _model.collection.drop()
    catch e
      L.error e

  L.success 'finished'

  return { elapsed: new Date() - start }

module.exports = {
  run
}

if !module.parent
  await run()
  exit 0


