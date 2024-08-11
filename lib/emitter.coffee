events = require 'events'
{ log, L } = require './logger'

class Eve extends events.EventEmitter
  constructor: ->
    super()

  logEmit: (x...) ->
    L.pending 'event', x...
    @emit x...

# Create a new EventEmitter instance
eve = new Eve()

# Shorthand emit function with logging
emit = (x...) ->
  eve.logEmit x...

module.exports = { eve, emit }

