# vim: set expandtab tabstop=2 shiftwidth=2 softtabstop=2
{ log } = console
{ env, exit } = process
{ mongoose, redis } = require './../../lib/database'

_ = require 'lodash'

Schema = mongoose.Schema

Affix = new Schema {
  _key: { type: String, required: true }

  modification: {
    type: String
    enum: [
      'amount'
      'multiplier'
    ]
    required: true
  }

  range: {
    type: [Number]
    required: true
  }

  gearSlots: {
    type: [String]
    enum: [
      'chest'
      'feet'
      'hands'
      'head'
      'legs'
      'augment'
      'primary'
      'secondary'
      'melee'
      'temporary'
    ]
  }

  description: {
    type: String
    default: '+#% to maximum life'
  }

  rarity: {
    type: Number
    min: constants.ITEM_RARITY_MIN
    max: constants.ITEM_RARITY_MAX
  }
}, { _id: false }

Affix.methods.roll = ((obj) ->
  throw new Error 'manual block'
)

Affix.statics.generate = ((item) ->
  throw new Error 'manual block'
)

module.exports = Affix

