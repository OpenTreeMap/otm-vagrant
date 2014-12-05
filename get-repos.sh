#!/bin/sh

for REPO in OTM2 ecobenefits OTM2-tiler
do
    echo
    if [ -e $REPO ]; then
        cd $REPO && git pull
        cd ..
    else
        git clone "https://github.com/OpenTreeMap/$REPO.git"
    fi
done
