otm2-vagrant
============

Vagrant files and scripts for setting up a local testing and development instance of OTM2

__NOTE:__ This repository is intended _only_ for development and testing.  It is not intended for setting up a production OTM2 server.

Currently, this setup will only work on a Linux host due to issues with symlinks and VirtualBox shared folders.

To get started, do the following steps:

 - Clone this repository
 - Run the script `get-repos.sh`
 - Run the command `vagrant up`
 
This will give you a working installation of OTM2, but without any maps.

To create a map do the following steps:

 - Create a user from your web browser (the URL should be `localhost:6060`)
 - SSH into the vagrant VM with `vagrant ssh`
 - Source the virtual environment using `source /usr/local/otm/env/bin/activate`
 - Change to the opentremap directory using `cd /usr/local/otm/app/opentreemap`
 - Run the `create_instance` management command using `./manage.py create_instance`.  For help on how to use `create_instance`, run `./manage.py create_instance -h`
