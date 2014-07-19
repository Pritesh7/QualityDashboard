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


# Installing Postgres
ADD ./postgres/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo

RUN yum localinstall -y http://yum.postgresql.org/9.3/redhat/rhel-6-x86_64/pgdg-centos93-9.3-1.noarch.rpm

RUN yum install -y postgresql93-server

RUN service postgresql-9.3 initdb

RUN chkconfig postgresql-9.3 on

CMD service postgresql-9.3 start

# Add Postgres bin directoy to path
RUN export PATH=$PATH:/usr/pgsql-9.3/bin

# Install psycopg2
RUN yum install -y python-psycopg2


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

# Install Pysolr
RUN pip install pysolr

# Install django
#RUN pip install django

# Start the new django project in the current directory
#RUN django-admin.py startproject dashboard

# Copy uwsgi params file into the docker container
#ADD ./nginx/uwsgi_params /home/quality_assurance/dashboard/uwsgi_params

# Copy nginx config file needed for server settings
# ADD ./nginx/dashboard_nginx.conf /home/quality_assurance/dashboard/dashboard/dashboard_nginx.conf

# Symlink the newly added config file to /etc/nginx/conf.d/
#RUN ln -s /home/quality_assurance/dashboard/dashboard_nginx.conf /etc/nginx/conf.d/

# Copy settings
#ADD ./django/solr_search/ /home/search/xbrl/solr_search

# Start nginx
#RUN /etc/init.d/nginx start

# Make port 8000 available to host
EXPOSE 8000

# Copy python scripts to container
ADD ./SolrMonitor /home/quality_assurance/SolrMonitor

