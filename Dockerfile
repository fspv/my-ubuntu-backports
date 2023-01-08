ARG DIST

FROM ubuntu:${DIST}

# Needed for Ubuntu 20.04 to suppress tz request on build
RUN ln -snf /usr/share/zoneinfo/UTC /etc/localtime
RUN echo UTC > /etc/timezone

RUN apt-get update; \
    apt-get install -y pbuilder aptitude gnupg2 ubuntu-dev-tools

ADD build.sh /build/

CMD ["/build/build.sh"]
