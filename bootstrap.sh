#!/bin/bash

set -e  # exit script early if any command fails
set -x  # print commands before executing them

# Add PPAs
sudo add-apt-repository -y ppa:ubuntu-toolchain-r/test
curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
apt-get update

apt-get install -yq python-software-properties python-setuptools git

cp -rTv --remove-destination /vagrant/configs /

# Stop all the services if they are already running
service otm-unicorn stop || true
service tiler stop || true
service ecoservice stop || true
service celery stop || true

# redis - needed for django
apt-get install -yq redis-server

# Django + GeoDjango
apt-get install -yq gettext libgeos-dev libproj-dev libgdal1-dev build-essential python-dev

# pip
cd /tmp
wget -nv https://bootstrap.pypa.io/get-pip.py
python get-pip.py pip==9.0.*

# DB
apt-get install -yq postgresql postgresql-server-dev-9.3 postgresql-contrib postgresql-9.3-postgis-2.1
service postgresql start

# Don't do any DB stuff if it already exists
if ! sudo -u postgres psql otm -c ''; then
    # Need to drop and recreate cluster to get UTF8 DB encoding
    sudo -u postgres pg_dropcluster --stop 9.3 main
    sudo -u postgres pg_createcluster --start 9.3 main  --locale="en_US.UTF-8"
    sudo -u postgres psql -c "CREATE USER otm SUPERUSER PASSWORD 'otm'"
    sudo -u postgres psql template1 -c "CREATE EXTENSION IF NOT EXISTS hstore"
    sudo -u postgres psql template1 -c "CREATE EXTENSION IF NOT EXISTS fuzzystrmatch"
    sudo -u postgres psql -c "CREATE DATABASE otm OWNER otm"
    sudo -u postgres psql otm -c "CREATE EXTENSION IF NOT EXISTS postgis"
fi

# Pillow
apt-get install -yq libfreetype6-dev

cd /usr/local/otm/app
pip install -r requirements.txt
pip install -r dev-requirements.txt
pip install -r test-requirements.txt

# Make local directories
mkdir -p /usr/local/otm/static || true
mkdir -p /usr/local/otm/media || true

apt-get install -yq nodejs
npm install -g yarn

# Bundle JS and CSS via webpack
yarn --force
python opentreemap/manage.py collectstatic_js_reverse
npm run build
python opentreemap/manage.py collectstatic --noinput

# For UI testing
apt-get install -yq xvfb
# We use an outdated version of firefox to avoid incompatibilities with selenium
wget -nv https://s3.amazonaws.com/packages.ci.opentreemap.org/firefox-mozilla-build_46.0.1-0ubuntu1_amd64.deb -O /tmp/firefox.deb
dpkg -i /tmp/firefox.deb

# Run Django migrations
python opentreemap/manage.py migrate
python opentreemap/manage.py create_system_user

# ecobenefits - init script
apt-get install -yq libgeos-dev mercurial
cd /usr/local/ecoservice
if ! go version; then
    wget -nv "https://storage.googleapis.com/golang/go1.6.3.linux-amd64.tar.gz" -O /tmp/go.tar.gz
    tar -C /usr/local -xzf /tmp/go.tar.gz
    sudo ln -s /usr/local/go/bin/go /usr/local/bin/go
fi
if ! which godep; then
    export GOPATH="/home/vagrant/.gopath"
    mkdir $GOPATH || true
    go get github.com/tools/godep
    sudo ln -sf $GOPATH/bin/godep /usr/local/bin/godep
fi
export GOPATH="/usr/local/ecoservice"
make build

# tiler
apt-get install -yq checkinstall g++ libstdc++-5-dev pkg-config libcairo2-dev libjpeg8-dev libgif-dev libpango1.0-dev
cd /usr/local/tiler

yarn --force

# nginx
apt-get install -yq nginx
rm /etc/nginx/sites-enabled/default || true
ln -sf /etc/nginx/sites-available/otm.conf /etc/nginx/sites-enabled/otm

chown -R vagrant:vagrant /usr/local/otm/static
chown -R vagrant:vagrant /usr/local/otm/media

initctl reload-configuration

service otm-unicorn start
service tiler start
service ecoservice start
service celery start
service nginx restart
