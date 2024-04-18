# vim: set expandtab tabstop=2 shiftwidth=2 softtabstop=2
signale = require 'signale'
{ Signale } = signale

signale.config(signaleConfig = {
  displayScope: true
  displayBadge: true
  displayDate: false
  displayFilename: false
  displayLabel: false
  displayTimestamp: false
  underlineLabel: false
  underlineMessage: false
  underlinePrefix: false
  underlineSuffix: false
  uppercaseLabel: false
})

getCallerFile = () ->
  originalFunc = Error.prepareStackTrace
  Error.prepareStackTrace = (_, stack) -> stack
  err = new Error
  stack = err.stack
  Error.prepareStackTrace = originalFunc
  stack[2]?.getFileName()

L = (args...) ->
  callerFile = getCallerFile()
  scope = callerFile.split('/api/').pop()
  logger = new Signale({ scope, config: signaleConfig })
  logger.info args...

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
      callerFile = getCallerFile()
      scope = callerFile.split('/api/').pop()
      logger = new Signale({ scope, config: signaleConfig })
      logger[method] args...

{ log } = console

module.exports = { L, log }

if !module.parent
  L 'hello, world'
  L.error new Error 'error message'
  L.fatal new Error 'hello there'

