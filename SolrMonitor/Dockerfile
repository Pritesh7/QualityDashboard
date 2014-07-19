################################################################################
# Docker file to build nginx hosted django site for xbrl solr search front end #
# Based on centos                                                              #
################################################################################

# Set the base images used
FROM centos:centos6

# File Author / Maintainer
MAINTAINER Joe Wogan

# Update the yum resource list to be used
RUN yum update -y

# Add epel to repository list to download nginx
RUN su -c 'rpm -Uvh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm'

# Install nginx
RUN yum install -y nginx

RUN cd /home

# Install python dev tools
RUN yum groupinstall -y "Development Tools"
RUN yum install -y python-devel zlib-devel

# Install wget to retrieve python source
RUN yum install -y wget

# Install pip
RUN wget https://raw.github.com/pypa/pip/master/contrib/get-pip.py
RUN python get-pip.py

# Install uwsgi
RUN pip install uwsgi

# Install Virtualenv
RUN pip install virtualenv

# Install virtualenvwrapper
RUN pip install virtualenvwrapper

# Create directory for Quality Assurance Dashboard
Run mkdir /home/quality_assurance

# Start the new virtual environment that the django site will be run from
RUN virtualenv /home/quality_assurance/env

# Make the virtual environment active
RUN source /home/quality_assurance/env/bin/activate

# Install django
RUN pip install django

# Start the new django project in the current directory
RUN django-admin.py startproject dashboard

# Copy uwsgi params file into the docker container
ADD ./nginx/uwsgi_params /home/quality_assurance/dashboard/uwsgi_params

# Copy nginx config file needed for server settings
# ADD ./nginx/xbrl_nginx.conf /home/search/xbrl/xbrl_nginx.conf

# Symlink the newly added config file to /etc/nginx/conf.d/
#RUN ln -s /home/search/xbrl/xbrl_nginx.conf /etc/nginx/conf.d/

# Copy settings
#ADD ./django/solr_search/ /home/search/xbrl/solr_search

# Start nginx
#RUN /etc/init.d/nginx start

# Make port 8000 available to host
EXPOSE 8000

# Install Postgresql-9.3
# Add the PostgreSQL PGP key to verify their Debian packages.
# It should be the same key as https://www.postgresql.org/media/keys/ACCC4CF8.asc
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8

# Add PostgreSQL's repository. It contains the most recent stable release
#     of PostgreSQL, ``9.3``.
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main" > /etc/apt/sources.list.d/pgdg.list

# Update the Ubuntu and PostgreSQL repository indexes
RUN apt-get update

# Install ``python-software-properties``, ``software-properties-common`` and PostgreSQL 9.3
#  There are some warnings (in red) that show up during the build. You can hide
#  them by prefixing each apt-get statement with DEBIAN_FRONTEND=noninteractive
RUN apt-get -y -q install python-software-properties software-properties-common
RUN apt-get -y -q install postgresql-9.3 postgresql-client-9.3 postgresql-contrib-9.3

# Note: The official Debian and Ubuntu images automatically ``apt-get clean``
# after each ``apt-get``

# Run the rest of the commands as the ``postgres`` user created by the ``postgres-9.3`` package when it was ``apt-get installed``
USER postgres

# Create a PostgreSQL role named ``docker`` with ``docker`` as the password and
# then create a database `docker` owned by the ``docker`` role.
# Note: here we use ``&&\`` to run commands one after the other - the ``\``
#       allows the RUN command to span multiple lines.
RUN    /etc/init.d/postgresql start &&\
    psql --command "CREATE USER docker WITH SUPERUSER PASSWORD 'docker';" &&\
    createdb -O docker docker

# Adjust PostgreSQL configuration so that remote connections to the
# database are possible.
RUN echo "host all  all    0.0.0.0/0  md5" >> /etc/postgresql/9.3/main/pg_hba.conf

# And add ``listen_addresses`` to ``/etc/postgresql/9.3/main/postgresql.conf``
RUN echo "listen_addresses='*'" >> /etc/postgresql/9.3/main/postgresql.conf

# Expose the PostgreSQL port
EXPOSE 5432

# Add VOLUMEs to allow backup of config, logs and databases
VOLUME  ["/etc/postgresql", "/var/log/postgresql", "/var/lib/postgresql"]

# Set the default command to run when starting the container
CMD ["/usr/lib/postgresql/9.3/bin/postgres", "-D", "/var/lib/postgresql/9.3/main", "-c", "config_file=/etc/postgresql/9.3/main/postgresql.conf"]