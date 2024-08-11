# vim: set expandtab tabstop=2 shiftwidth=2 softtabstop=2
{ log, L } = require './logger'
{ env, exit } = process

_ = require 'lodash'
pluralize = require 'pluralize'

helpers = require './helpers'
{ emit } = require './emitter'

models = {}

models.basePlugin = (schema) ->
  schema.add
    _id: String
    mtime: Number
    ctime: Number
    etime: Number

  schema.pre 'save', (next) ->
    @_id ?= helpers.uuid()
    @mtime = helpers.time()
    @ctime ?= @mtime
    
    next()

  # reset to default
  schema.methods._resetPath = (fieldPath) ->
    pathParts = _.toPath(fieldPath)
    lastKey = _.last(pathParts)

    parentPath = _.initial(pathParts).join('.')
    parentObject = if parentPath then _.get(@, parentPath) else @

    lastSchema = @constructor.schema.path(fieldPath)

    defaultValue = lastSchema?.options?.default
    _.set(@, fieldPath, _.cloneDeep(defaultValue) ? undefined)

# auto expose model to rest
models.EXPOSE = (model, opts = {}) ->
  if opts?.route
    model.EXPOSE = opts
    return model

  opts = {
    route: "/#{model.collection.name}"
    methods: _.keys(model.schema.methods)
    statics: _.keys(model.schema.statics)
  }

  model.EXPOSE = opts
  return model

module.exports = models

