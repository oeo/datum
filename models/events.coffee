# vim: set expandtab tabstop=2 shiftwidth=2 softtabstop=2
{ log } = console
{ env } = process

{ mongoose, redis } = require './../lib/database'

Schema = mongoose.Schema
{ basePlugin, EXPOSE } = require './../lib/models'

modelOpts = {
  name: 'Event'
  schema: {
    collection: 'events'
    strict: false
  }
}

Event = new Schema {

  event: {
    type: String
    required: true
  }

  player: {
    type: String
  }

}, modelOpts.schema

Event.plugin(basePlugin)

Event.methods.changeEvent = ({ newEvent }) ->
  @event = newEvent

  try
    return await @save()
  catch e
    return e

Event.statics.ping = ({ name }) ->
  return { pong: name }

model = mongoose.model modelOpts.name, Event
module.exports = EXPOSE(model)

