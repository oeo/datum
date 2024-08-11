# vim: set expandtab tabstop=2 shiftwidth=2 softtabstop=2
{ log, L } = require './logger'
{ env, exit } = process

_ = require 'lodash'
url = require 'url'
qs = require 'querystring'
crypto = require 'crypto'

UUID = require('short-unique-id')
uuid = new UUID { length: 10 }

helpers = {
  uuid: -> uuid.rnd()
  wait: (ms) ->
    new Promise (resolve, reject) ->
      setTimeout resolve, ms
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
  return Math.floor(Date.now() / 1000)

helpers.extendAll = (arr, obj) ->
  arr = _.map arr, (x) ->
    x[k] ?= v for k, v of obj
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

helpers.appendQueryString = (urlStr, objs...) ->
  urlParts = url.parse(urlStr)
  append = []

  try append.push qs.parse(urlParts.query)

  for obj in objs
    # url str
    if typeof obj is 'string' and obj.indexOf('://') > -1
      parts = url.parse obj
      try append.push qs.parse(parts.query)
      continue

    # query str
    if typeof obj is 'string'
      if obj.substr(0, 1) is '?' then obj = obj.substr(1)
      continue if !obj.trim()
      try append.push qs.parse(obj)
      continue

    if typeof obj is 'object' and obj
      append.push obj
      continue

  return urlStr if !append.length

  appendObj = {}

  for x in append
    appendObj[k] = v for k, v of x

  url.resolve(urlStr, '?' + qs.stringify(appendObj))

helpers.sha256 = (str, salt = null, globalSalt = false) ->
  hash = crypto.createHash 'sha256'

  hashStr = str

  if salt then hashStr += salt
  if globalSalt then hashStr += env.GLOBAL_SALT

  hash.update hashStr
  hash.digest 'hex'

helpers.sortObject = (obj) ->
  if Array.isArray(obj)
    return obj.map(helpers.sortObject)
  else if typeof obj is 'object' and obj isnt null
    sorted = {}
    Object.keys(obj).sort().forEach (key) ->
      sorted[key] = helpers.sortObject(obj[key])
    return sorted
  else
    return obj

helpers.integrityHash = (obj, returnDetails = false) ->
  clone = _.cloneDeep(obj)
  delete clone.integrityHash if clone.integrityHash?

  sortedClone = helpers.sortObject(clone)
  cloneString = JSON.stringify(sortedClone)

  integritySalt = "integrity:#{cloneString.length}"
  firstHash = helpers.sha256(cloneString)
  secondHash = helpers.sha256(firstHash, integritySalt, false)

  if returnDetails
    return {
      integritySalt
      firstHash
      secondHash
      integrityHash: secondHash
    }

  return secondHash

helpers.validateIntegrityHash = (obj, providedHash = null) ->
  return false if typeof obj isnt 'object'

  if providedHash?
    hashToValidate = providedHash
    objToHash = obj
  else if obj.integrityHash?
    hashToValidate = obj.integrityHash
    objToHash = _.cloneDeep(obj)
    delete objToHash.integrityHash
  else
    return false

  calculatedHash = helpers.integrityHash(objToHash)
  return calculatedHash is hashToValidate

module.exports = helpers

if !module.parent
  testObj = {
    "birth_date": "07/09/1942",
    "city": "Coraopolis",
    "group": null,
    "email": "taky@taky.com",
    "fname": "taky",
    "social": "805-37-770",
    "identity_document_expiration": "01/01/2025",
    "identity_document_issuer": "USA",
    "identity_document_number": "10ABC51239",
    "identity_document_type": "Passport",
    "lname": "PERSINGER",
    "phone": "18149233715",
    "zip": "15108",
    "state": "PA",
    "street": "1045 W 27th",
    "document_tokens": {
      "front": "bc3e79f0b4ed4ecb88b396b61fa7b9b5",
      "back": "3ddf918d43494e5ca7938d1ec54ec3a1"
    },
    "uuid": "97f5d43181c94b6f860043ece08102c5",
    "fullAddress": "310 Scenic Ct, Coraopolis, PA 15108"
  }

  testObj2 = {
    "fullAddress": "310 Scenic Ct, Coraopolis, PA 15108"
    "birth_date": "07/09/1942",
    "city": "Coraopolis",
    "group": null,
    "email": "taky@taky.com",
    "fname": "taky",
    "identity_document_expiration": "01/01/2025",
    "social": "805-37-770",
    "identity_document_issuer": "USA",
    "identity_document_number": "10ABC51239",
    "identity_document_type": "Passport",
    "lname": "PERSINGER",
    "phone": "18149233715",
    "zip": "15108",
    "state": "PA",
    "street": "1045 W 27th",
    "document_tokens": {
      "front": "bc3e79f0b4ed4ecb88b396b61fa7b9b5",
      "back": "3ddf918d43494e5ca7938d1ec54ec3a1"
    },
    "uuid": "97f5d43181c94b6f860043ece08102c5",
  }

  log /testObj/, testObj
  log /integrityHash/, integrityHash = helpers.integrityHash(testObj, true)
  log /normalSha/, integrityHash.firstHash
  log /validateIntegrityHash/, helpers.validateIntegrityHash(testObj, integrityHash.integrityHash)

  log '----------------'

  for x in [1..2]
    log /testObj2/, testObj2
    log /integrityHash2/, integrityHash2 = helpers.integrityHash(testObj2, true)
    log /normalSha2/, integrityHash2.firstHash
    log /validateIntegrityHash2/, helpers.validateIntegrityHash(testObj2, integrityHash2.integrityHash)
    if x is 1
      try delete testObj2.zip

  log '----------------'

  testObj3 = _.cloneDeep(testObj2)
  testObj3.integrityHash = helpers.integrityHash(testObj3)

  log /testObj3/, testObj3
  log /integrityHash3/, integrityHash3 = helpers.integrityHash(testObj3, true)
  log /validateIntegrityHash3/, helpers.validateIntegrityHash(testObj3)

  exit 0

