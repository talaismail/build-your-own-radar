FROM registry.access.redhat.com/ubi8/nodejs-16 AS build

WORKDIR /src/build-your-own-radar
COPY --chown=1001 package.json /src/build-your-own-radar
RUN npm install

COPY --chown=1001 . /src/build-your-own-radar
USER 1001
RUN npm run build:prod

FROM registry.access.redhat.com/ubi8/nginx-120 
USER root
RUN mkdir -p files
RUN mkdir -p images
COPY --from=build /src/build-your-own-radar/dist/* .
COPY --from=build /src/build-your-own-radar/src/images/* ./images/
COPY --from=build /src/build-your-own-radar/spec/end_to_end_tests/resources/localfiles/* ./files/
COPY nginx.conf /etc/nginx/nginx.conf
RUN  chown -R 1001:0 /opt/app-root/src &&  chmod -R g=u /opt/app-root/src
USER 1001
CMD nginx -g "daemon off;"