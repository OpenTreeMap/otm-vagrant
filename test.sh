#!/bin/sh

# OTM2
cd /usr/local/otm/app

# OTM2 Django unit tests
fab me test:coverage=True

# OTM2 Django UI tests
fab me uitest:coverage=True

# OTM2 JS tests
testem ci

# Ecobenefits
cd /usr/local/ecoservice
make test

# OTM2-tiler
cd /usr/local/tiler
make test
