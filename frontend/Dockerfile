FROM node:slim

COPY package*.json .

RUN npm install 

COPY . .

EXPOSE 3000

ENV NEXT_PUBLIC_API_BASE_URL=http://nginx/api

CMD [ "npm","run","dev" ]