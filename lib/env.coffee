# vim: set expandtab tabstop=2 shiftwidth=2 softtabstop=2
{ log } = console
{ env } = process

if not env.ENV_SET
  env.ENV_SET = 1

  require('dotenv').config {
    path: (if env.NODE_ENV is 'production' then __dirname + '/../.env.production' else __dirname + '/../.env')
    path: (do =>
      if env.NODE_ENV is 'production'
        return __dirname + '/../.env.production'
      if env.NODE_ENV is 'stage'
        return __dirname + '/../.env.stage'
      else
        return __dirname + '/../.env'
    )
  }

