FROM quay.io/baselibrary/ubuntu:14.04
MAINTAINER ShawnMa <qsma@thoughtworks.com>

## Add repository
RUN \
  apt-key adv --keyserver keyserver.ubuntu.com --recv-keys ACCC4CF8 &&\
  echo "deb http://apt.postgresql.org/pub/repos/apt trusty-pgdg main" > /etc/apt/sources.list.d/postgres.list

## Install packages
RUN \
  apt-get update &&\
  apt-get install -y postgresql-9.2-postgis-2.1 postgresql-contrib-9.2 python-psycopg2 &&\
  rm -rf /var/lib/apt/lists/*

## Install scripts
ADD docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod a+x            /docker-entrypoint.sh

## Set environment variable
ENV PATH   /usr/lib/postgresql/9.2/bin:$PATH
ENV PGDATA /var/lib/postgresql/data

EXPOSE 5432

ENTRYPOINT ["tini", "--", "/docker-entrypoint.sh"]

VOLUME ["/var/lib/postgresql/data"]

CMD ["postgres"]


