# FROM openjdk:jre-alpine
FROM openjdk:jre

RUN apt-get update && apt-get install -y perl

COPY . /Fgenesb_CGView

WORKDIR /Fgenesb_CGView

ENTRYPOINT ["/bin/bash", "/Fgenesb_CGView/run.sh"]