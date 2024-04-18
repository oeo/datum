# vim: set expandtab tabstop=2 shiftwidth=2 softtabstop=2
{ log } = console
{ env, exit } = process

crypto = require 'crypto'
CryptoJS = require 'crypto-js'

sha256 = (data) ->
  unless typeof data is 'string'
    try
      data = JSON.stringify data
    catch error
      console.error 'Error stringifying data in sha256:', error

  crypto.createHash('sha256').update(data).digest('hex')

toUrlSafe = (str) ->
  str.replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '')

fromUrlSafe = (str) ->
  str += '==='.slice(0, (3 * str.length) % 4)
  str.replace(/-/g, '+').replace(/_/g, '/')

encrypt = (message, secret) ->
  unless typeof message is 'string'
    try
      message = JSON.stringify message
    catch error
      console.error 'Error stringifying message in encrypt:', error

  try
    secret = secret.toString()
  catch error
    console.error 'Error converting secret to string in encrypt:', error

  encrypted = CryptoJS.AES.encrypt message, secret
  toUrlSafe encrypted.toString()

decrypt = (ciphertext, secret) ->
  try
    secret = secret.toString()
  catch error
    console.error 'Error converting secret to string in decrypt:', error

  ciphertext = fromUrlSafe ciphertext
  bytes = CryptoJS.AES.decrypt ciphertext, secret
  str = bytes.toString CryptoJS.enc.Utf8

  try str = JSON.parse str

  str

if !module.parent
  for x in [
    'Hello, world'
    Math.random()
    {test:'yes'}
  ]
    tmp = {orig:x}
    tmp.encrypted = encrypt(x,'test-salt')
    tmp.decrypted = decrypt(tmp.encrypted,'test-salt')
    log tmp
  exit 0

module.exports = {
  encrypt: encrypt
  decrypt: decrypt
  sha256: sha256
}

