#!/bin/sh

# Add PPAs
apt-get update

apt-get install -yq python-software-properties python-setuptools stow git

add-apt-repository -y ppa:mapnik/boost
add-apt-repository -y ppa:mapnik/v2.1.0
add-apt-repository -y ppa:chris-lea/node.js
add-apt-repository -y ppa:ubuntugis/ppa

apt-get update

easy_install pip

cd /vagrant
stow -vv -t / configs

# nodejs & redis - needed for django and tiler
apt-get install -yq nodejs redis-server

# Django
apt-get install -yq gettext

# DB
apt-get install -yq postgresql postgresql-server-dev-9.1 postgresql-contrib postgresql-9.1-postgis
service start postgres
sudo -u postgres psql -c "CREATE USER otm SUPERUSER PASSWORD 'password'"
sudo -u postgres psql template1 -c "CREATE EXTENSION IF NOT EXISTS hstore"
sudo -u postgres psql template1 -c "CREATE EXTENSION IF NOT EXISTS postgis"
sudo -u postgres psql -c "CREATE DATABASE otm OWNER otm"

# PIL
apt-get install -yq libfreetype6-dev zlib1g-dev libpq-dev python-dev libxml2-dev libgeos-dev libproj-dev libgdal1-dev build-essential

# OTM2
# TODO: Selenium is not in the Ubuntu repos... apt-get install -yq selenium xvfb
cd /usr/local/otm/app
pip install -r requirements.txt
pip install -r dev-requirements.txt
pip install -r test-requirements.txt
# init script?

# OTM2 client-side bundle
npm install
# Weird issues with newest version of grunt in combination with grunt-browserify
npm install -g grunt-cli@0.1.9
# TODO: Keep getting permission issues
grunt --dev

# Run South migrations
fab me syncdb

# ecobenefits - init script
apt-get install -yq libgeos-dev
wget "https://go.googlecode.com/files/go1.2.linux-amd64.tar.gz" -O /tmp/go.tar.gz
tar -C /usr/local -xzf /tmp/go.tar.gz
export PATH="$PATH:/usr/local/go/bin"
export GOPATH="/usr/local/ecoservice"
cd /usr/local/ecoservice
go get -v github.com/azavea/ecobenefits
go build github.com/azavea/ecobenefits

# tiler
apt-get install -yq libsigc++-2.0-dev libmapnik-dev mapnik-utils
cd /usr/local/tiler
npm install

# nginx
apt-get install -yq nginx
# 1) install 2) config file

# start all the things via otm2 fab script
