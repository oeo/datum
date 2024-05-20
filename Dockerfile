FROM node:dubnium-alpine

WORKDIR /usr/src/app

COPY . .

RUN yarn install --ignore-engines

EXPOSE 10001

CMD [ "yarn", "--ignore-engines", "heroku-start-api" ]

