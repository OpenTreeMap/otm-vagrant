#!/bin/sh

for url in https://github.com/OpenTreeMap/OTM2.git https://github.com/OpenTreeMap/ecobenefits.git https://github.com/OpenTreeMap/OTM2-tiler.git
do
    echo
    git clone "$url"
done
