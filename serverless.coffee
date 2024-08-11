fs = require 'fs'
path = require 'path'
dotenv = require 'dotenv'
packageJson = require './package.json'

NODE_ENV = STAGE = process.env.NODE_ENV ? 'staging'

requiredVars = [
  'NODE_ENV'
  'STAGE'
  'SERVERLESS_ORG'
]

blacklistedVars = [
  'AWS_REGION'
  'AWS_ACCESS_KEY_ID'
  'AWS_SECRET_ACCESS_KEY'
]

# Get a list of .env files
getEnvFiles = ->
  files = fs.readdirSync('.').filter (file) -> file.startsWith('.env.')
  files.map (file) -> path.join('.', file)

# Check if .env.#{NODE_ENV} exists, otherwise use .env
getEnvFile = ->
  envFiles = getEnvFiles()
  specificEnv = ".env.#{NODE_ENV}"
  if fs.existsSync(specificEnv)
    specificEnv
  else
    '.env'

# Load environment variables
loadEnv = (file) ->
  envObj = dotenv.parse(fs.readFileSync(file))
  envObj.STAGE = NODE_ENV
  
  # Check required variables
  for requiredVar in requiredVars
    if !envObj[requiredVar]
      throw new Error "Missing required environment variable: #{requiredVar}"

  # Remove blacklisted variables
  for blacklistedVar in blacklistedVars
    delete envObj[blacklistedVar]

  envObj

pluginsList = (->
  list = []

  if NODE_ENV isnt 'production'
    list.push 'serverless-offline'

  return list
)

# Load environment
envFile = getEnvFile()
envObj = loadEnv(envFile)

module.exports = {
  org: envObj.SERVERLESS_ORG
  app: packageJson.name
  service: packageJson.name
  provider: {
    name: 'aws'
    runtime: 'nodejs18.x'
    stage: NODE_ENV
    environment: envObj
    logs:
      restApi:
        accessLogging: true
        format: '{ "requestId":"$context.requestId", "ip": "$context.identity.sourceIp", "caller":"$context.identity.caller", "user":"$context.identity.user", "requestTime":"$context.requestTime", "httpMethod":"$context.httpMethod", "resourcePath":"$context.resourcePath", "status":"$context.status", "protocol":"$context.protocol", "responseLength":"$context.responseLength" }'
        executionLogging: true
        level: 'INFO'
        fullExecutionData: true
    apiGateway:
      metrics: true # Enable API Gateway metrics
    logRetentionInDays: 30 # Set log retention period
  }
  functions: {
    app: {
      handler: 'app.handler'
      events: [
        {
          http: {
            method: 'any'
            path: '/'
            cors: true
          }
        }
        {
          http: {
            method: 'any'
            path: '/{proxy+}'
            cors: true
          }
        }
      ]
    }
  }
  plugins: pluginsList()
  custom: {
    'serverless-offline': {
      httpPort: 3000
    }
  }
}

