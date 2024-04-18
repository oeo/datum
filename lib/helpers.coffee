# vim: set expandtab tabstop=2 shiftwidth=2 softtabstop=2
{ log, L } = require './logger'
{ env, exit } = process

_ = require 'lodash'

UUID = require('short-unique-id')

uuid = new UUID { length: 10 }

helpers = {
  uuid: -> uuid.rnd()
  wait: (ms) ->
    new Promise (resolve, reject) ->
      setTimeout res, ms
}

helpers.validEmail = (email) ->
  return false unless typeof email is 'string'
  regex = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
  return regex.test email

_normalizeableProviders = {
  'gmail.com':
    cut: PLUS_AND_DOT = /\.|\+.*$/g
  'googlemail.com':
    cut: PLUS_AND_DOT
    aliasOf: 'gmail.com'
  'hotmail.com':
    cut: PLUS_ONLY = /\+.*$/
  'live.com':
    cut: PLUS_AND_DOT
  'outlook.com':
    cut: PLUS_ONLY
}

helpers.normalizeEmail = (str) ->
  email = str.trim().toLowerCase()
  emailParts = email.split /@/

  return str unless emailParts.length is 2

  [username, domain] = emailParts

  if _normalizeableProviders.hasOwnProperty domain
    username = username.replace _normalizeableProviders[domain].cut, '' if _normalizeableProviders[domain].hasOwnProperty 'cut'
    domain = _normalizeableProviders[domain].aliasOf if _normalizeableProviders[domain].hasOwnProperty 'aliasOf'

  while username.includes(' ')
    username = username.split(' ').join('')

  return username + '@' + domain

helpers.validUsername = (username = null) ->
  username = '' if !username

  if username.length < 3 or username.length > 16
    return false

  if !(/^[a-zA-Z0-9]+$/.test(username))
    return false

  return true

helpers.normalizeUsername = (username = null) ->
  username = '' if !username
  return username.trim().toLowerCase()

helpers.ucwords = (str) ->
  str.split(' ').map((word) ->
    word.charAt(0).toUpperCase() + word.slice(1)
  ).join(' ')

helpers.ucfirst = (str) ->
  str.charAt(0).toUpperCase() + str.slice(1)

helpers.deepPick = (obj, paths) ->
  result = {}
  for path in paths
    value = _.get(obj, path)
    _.set(result, path, value)
  result

helpers.time = (format = 'unix') ->
  if format is 'ms' then return Date.now()
  return Math.floor(Date.now()/1000)

helpers.extendAll = (arr, obj) ->
  arr = _.map arr, (x) ->
    x[k] ?= v for k,v of obj
    x
  arr

helpers.secondsToHuman = (seconds) ->
  return '0s' unless seconds > 0

  days = Math.floor(seconds / (24 * 3600))
  seconds %= (24 * 3600)
  hours = Math.floor(seconds / 3600)
  seconds %= 3600
  minutes = Math.floor(seconds / 60)
  seconds %= 60

  result = ''
  result += "#{days}d" if days > 0
  result += "#{hours}h" if days == 0 and hours > 0
  result += "#{minutes}m" if days == 0 and hours == 0 and minutes > 0
  result += "#{seconds}s" if days == 0 and hours == 0 and minutes == 0 and seconds > 0

  result

helpers.uriTitle = (str, delimiter = '_') ->
  str = str.trim().toLowerCase()
    .replace(/[^\w]/g, ' ')

  while str.includes('  ')
    str = str.split('  ').join(' ').trim()

  return str.split(' ').join(delimiter)

helpers.sleep = (ms) ->
  new Promise (resolve, reject) ->
    setTimeout resolve, ms

module.exports = helpers

