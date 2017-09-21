#!/bin/bash
set -e

cd /usr/local/tiler
make test

cd /usr/local/ecoservice
godep go test eco/*

cd /usr/local/otm/app/
yarn run check

xvfb-run yarn run test

flake8 --exclude migrations,opentreemap/settings/local_settings.py opentreemap
# Need to build assets before running the UI tests
python opentreemap/manage.py collectstatic_js_reverse
yarn run build
python opentreemap/manage.py collectstatic --noinput

cd opentreemap
python manage.py test
xvfb-run python manage.py test  -p 'uitest*.py'
