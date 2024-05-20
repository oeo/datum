# vim: set expandtab tabstop=2 shiftwidth=2 softtabstop=2
{ log, L } = require './../lib/logger'
{ exit, env } = process

require './../lib/env'

{ mongoose, redis, connected } = require './../lib/database'

helpers = require './../lib/helpers'

_ = require 'lodash'

{
  Events
} = require './../models'

run = ->
  await connected()

  start = new Date

  models = require './../models'

  for x in [1..(max = 100)]
    resp = await models.Events.create {
      event: _.first _.shuffle ['user_signup','interface_click','user_login']
      name: _.first _.shuffle ['John Smith', 'Chris Miller', 'Tom Joe']
    }

  L.success 'Created new events documents', { amount: max }

  return { elapsed: new Date() - start }

module.exports = {
  run
}

if !module.parent
  await run()
  exit 0

