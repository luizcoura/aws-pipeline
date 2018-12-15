FROM node:8

WORKDIR /app

COPY package*.json ./
COPY app.js ./

RUN yarn

EXPOSE 8080
CMD [ "npm", "start" ]
