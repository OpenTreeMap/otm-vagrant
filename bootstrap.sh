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
apt-get install nodejs redis

# Django
apt-get install -yq gettext

# DB
apt-get install -yq postgres postgresql-server-dev-9.1 postgresql-contrib postgresql-9.1-postgis
service start postgres
sudo postgres -c psql -c "CREATE USER otm SUPERUSER PASSWORD password"
sudo postgres -c psql template1 -c "CREATE EXTENSION IF NOT EXISTS hstore"
sudo postgres -c psql template1 -c "CREATE EXTENSION IF NOT EXISTS postgis"
sudo postgres -c psql -c "CREATE DATABASE otm OWNER otm"

# PIL
apt-get install -yq libfreetype6-dev zlib1g-dev libpq-dev python-dev libxml2-dev libgeos-dev libproj-dev libgdal1-dev build-essential

# OTM2
apt-get install -yq selenium xvfb
pip install -r otm/requirements.txt
pip install -r otm/dev-requirements.txt
pip install -r otm/test-requirements.txt
# init script?

pushd /usr/local/otm/app
# OTM2 client-side bundle
npm install
npm install -g grunt-cli
grunt --dev

# Run South migrations
fab me syncdb
popd

# ecobenefits - init script
apt-get install -yq libgeos-dev git
wget "https://go.googlecode.com/files/go1.2.linux-amd64.tar.gz" -O /tmp/go.tar.gz
tar -C /usr/local -xzf /tmp/go.tar.gz
export PATH="$PATH:/usr/local/go/bin"
export GOPATH="/usr/local/ecoservice"
go get -v github.com/azavea/ecobenefits
go build github.com/azavea/ecobenefits

# tiler
apt-get install -yq libsigc++-2.0-dev libmapnik-dev mapnik-utils
push /usr/local/otm/tiler
npm install
popd

# nginx
apt-get install -yq nginx
# 1) install 2) config file

# start all the things via otm2 fab script
