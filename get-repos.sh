#!/bin/sh

for REPO in otm-core otm-ecoservice otm-tiler
do
    echo
    if [ -e $REPO ]; then
        cd $REPO && git pull
        cd ..
    else
        git clone "https://github.com/OpenTreeMap/$REPO.git"
    fi
done
