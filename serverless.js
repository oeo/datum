// vim: set expandtab tabstop=2 shiftwidth=2 softtabstop=2
const packageJson = require('./package.json');
const majorVersion = packageJson.version.split('.')[0];

let NODE_ENV = (process.env.NODE_ENV || 'staging')
let STAGE = NODE_ENV

module.exports = {
  org: packageJson.name,
  app: packageJson.name,
  service: packageJson.name,
  frameworkVersion: '3',
  provider: {
    name: 'aws',
    runtime: 'nodejs18.x',
    stage: STAGE,
    environment: {
      NODE_ENV,
      STAGE,
    },
  },
  functions: {
    app: {
      handler: 'app.handler',
      events: [
        {
          http: {
            method: 'any',
            path: '/',
            cors: true,
          },
        },
        {
          http: {
            method: 'any',
            path: '/{proxy+}',
            cors: true,
          },
        },
      ],
    },
  },
  plugins: [
    'serverless-offline',
    'serverless-dotenv-plugin',
    //'serverless-domain-manager',
  ],
  custom: {
    dotenv: {
      basePath: './',
      include: [`.env.${NODE_ENV}`],
    },
    'serverless-offline': {
      httpPort: 3000,
    },
  },
};

