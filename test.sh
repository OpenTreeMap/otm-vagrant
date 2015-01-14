#!/bin/bash
set -e

cd /usr/local/tiler
make test

cd /usr/local/ecoservice
godep go test eco/*

cd /usr/local/otm/app/
grunt check

export DISPLAY=":99.0"
Xvfb $DISPLAY 2>/dev/null >/dev/null &
testem ci

source /usr/local/otm/env/bin/activate
flake8 --exclude migrations,opentreemap/settings/local_settings.py opentreemap
# Need to run grunt before running the UI tests
grunt
python opentreemap/manage.py test
python opentreemap/manage.py test  -p 'uitest*.py'
