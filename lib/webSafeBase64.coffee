{ log, L } = require './logger'

# encoding function
encodeWebSafe = (input) ->
  if typeof input == 'object'
    input = JSON.stringify(input)
  base64 = btoa(unescape(encodeURIComponent(input)))
  base64.replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '')

# decoding function
decodeWebSafe = (input) ->
  base64 = input.replace(/-/g, '+').replace(/_/g, '/')
  decoded = decodeURIComponent(escape(atob(base64)))
  try
    JSON.parse(decoded)
  catch
    decoded

module.exports = {
  encodeWebSafe
  decodeWebSafe
}

