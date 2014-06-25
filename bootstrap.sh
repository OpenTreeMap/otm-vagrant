#!/bin/sh

# Make the script exit early if any command fails
set -e

# Add PPAs
apt-get update

apt-get install -yq python-software-properties python-setuptools stow git

add-apt-repository -y ppa:mapnik/boost
add-apt-repository -y ppa:mapnik/v2.1.0
add-apt-repository -y ppa:chris-lea/node.js
add-apt-repository -y ppa:ubuntugis/ppa

apt-get update

cd /vagrant
stow -vv -t / configs

# nodejs & redis - needed for django and tiler
apt-get install -yq nodejs redis-server

# Django + GeoDjango
apt-get install -yq gettext libgeos-dev libproj-dev libgdal1-dev build-essential python-pip python-dev sendmail
pip install virtualenv

# DB
apt-get install -yq postgresql postgresql-server-dev-9.1 postgresql-contrib postgresql-9.1-postgis-2.0
service postgresql start
# Need to drop and recreate cluster to get UTF8 DB encoding
sudo -u postgres pg_dropcluster --stop 9.1 main
sudo -u postgres pg_createcluster --start 9.1 main  --locale="en_US.UTF-8"
sudo -u postgres psql -c "CREATE USER otm SUPERUSER PASSWORD 'password'"
sudo -u postgres psql template1 -c "CREATE EXTENSION IF NOT EXISTS hstore"
sudo -u postgres psql -c "CREATE DATABASE otm OWNER otm"
sudo -u postgres psql otm -c "CREATE EXTENSION IF NOT EXISTS postgis"

# Pillow
apt-get install -yq libfreetype6-dev zlib1g-dev libpq-dev libxml2-dev

# OTM2
apt-get install -yq xvfb firefox

cd /usr/local/otm
virtualenv env

cd /usr/local/otm/app
/usr/local/otm/env/bin/pip install -r requirements.txt
/usr/local/otm/env/bin/pip install -r dev-requirements.txt
/usr/local/otm/env/bin/pip install -r test-requirements.txt
# init script?

# OTM2 client-side bundle
npm install
# Weird issues with newest version of grunt in combination with grunt-browserify
npm install -g grunt-cli@0.1.9
grunt --dev

# Run South migrations
/usr/local/otm/env/bin/python opentreemap/manage.py syncdb
/usr/local/otm/env/bin/python opentreemap/manage.py migrate
/usr/local/otm/env/bin/python opentreemap/manage.py create_system_user

# Make local directories
mkdir /usr/local/otm/static
mkdir /usr/local/otm/media
chown vagrant:vagrant /usr/local/otm/static
chown vagrant:vagrant /usr/local/otm/media

# Copy over static files
/usr/local/otm/env/bin/python opentreemap/manage.py collectstatic --noinput

# ecobenefits - init script
apt-get install -yq libgeos-dev
wget "https://go.googlecode.com/files/go1.2.linux-amd64.tar.gz" -O /tmp/go.tar.gz
tar -C /usr/local -xzf /tmp/go.tar.gz
export PATH="$PATH:/usr/local/go/bin"
export GOPATH="/usr/local/ecoservice"
cd /usr/local/ecoservice
go get -v github.com/OpenTreeMap/ecobenefits
go build github.com/OpenTreeMap/ecobenefits

# tiler
apt-get install -yq libsigc++-2.0-dev libmapnik-dev mapnik-utils
cd /usr/local/tiler
npm install

# nginx
apt-get install -yq nginx
rm /etc/nginx/sites-enabled/default

initctl reload-configuration

service otm-unicorn start
service tiler start
service ecoservice start
service nginx start
