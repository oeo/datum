# vim: set expandtab tabstop=2 shiftwidth=2 softtabstop=2
{ log } = console

signale = require 'signale'
{ Signale } = signale

signale.config(signaleConfig = {
  displayScope: true
  displayBadge: true
  displayDate: false
  displayFilename: false
  displayLabel: false
  displayTimestamp: true
  underlineLabel: false
  underlineMessage: false
  underlinePrefix: false
  underlineSuffix: false
  uppercaseLabel: false
})

baseFolder = ->
  require('path').resolve(__dirname + './..')

getCallerFile = () ->
  originalFunc = Error.prepareStackTrace
  Error.prepareStackTrace = (_, stack) -> stack
  err = new Error
  stack = err.stack
  Error.prepareStackTrace = originalFunc
  stack[2]?.getFileName()

L = (args...) ->
  scope = getCallerFile()
    .split(baseFolder() + '/')
    .join('')
  logger = new Signale({ scope, config: signaleConfig })
  logger.log args...

# attach other Signale methods to L
methods = """
  await
  complete
  error
  debug
  fatal
  fav
  info
  note
  pause
  pending
  star
  start
  success
  wait
  warn
  watch
  log
""".split '\n'

for method in methods
  do (method) ->
    L[method] = (args...) ->
      scope = getCallerFile()
        .split(baseFolder() + '/')
        .join('')

      logger = new Signale({ scope, config: signaleConfig })
      logger[method] args...

module.exports = { L, log }

if !module.parent
  L 'hello, world'
  L.error new Error 'error message'
  L.fatal new Error 'hello there'

