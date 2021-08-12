otm-vagrant
===========

Vagrant files and scripts for setting up a local testing and development instance of OpenTreeMap (OTM)

__NOTE:__ This repository is intended _only_ for development and testing.  It is not intended for setting up a production OTM server.

To get started, do the following steps:

 - Install [Vagrant](http://www.vagrantup.com/) and [VirtualBox](https://www.virtualbox.org/)
 - Clone this repository
 - Create a [Google Maps API key](https://developers.google.com/maps/documentation/javascript/get-api-key) and replace the `GOOGLE_MAPS_KEY` in  `configs/etc/init/otm-unicorn.conf` with the key you created
 - Create a [Esri API credentials](https://developers.arcgis.com/documentation/core-concepts/security-and-authentication/accessing-arcgis-online-services/) and replace the `ESRI_CLIENT_ID` and `ESRI_CLIENT_SECRET` in  `configs/etc/init/otm-unicorn.conf` with the credentials you created
 - Run the script `get-repos.sh`
 - Run the command `vagrant up`

This will give you a working installation of OTM, but without any maps.

To create a map do the following steps:

 - Create a user from your web browser (the URL should be `localhost:7070`). The email will be written to a file in `/usr/local/otm/emails/` inside the VM
 - SSH into the vagrant VM with `vagrant ssh`
 - Read the email with your user activation link (`cat /usr/local/otm/emails/*`) and activate the user by pasting the URL in it into your browser
 - Change to the opentreemap directory using `cd /usr/local/otm/app/opentreemap`
 - Create a tree map using the `create_instance` management command, passing the username you created above. For example, to create a tree map with name "Philadelphia", url name `philly`, and admin user "sue", centered at longitude -75.1 and latitude 40.0:

```sh
    ./manage.py create_instance Philadelphia --url_name=philly --user=sue --center=-75.1,40.0
```

For further help on how to use `create_instance`, run `./manage.py create_instance -h`

## Windows

To run on Windows you must install [Cygwin](https://www.cygwin.com) (including `rsync` and `openssh`) and start a Unix shell like `bash` to run the install scripts.

On Windows the OTM source code is shared with the virtual machine via a one-way `rsync` from Windows host to Ubuntu guest. When you update source code files you must run `vagrant rsync` from your Windows Unix shell. See also [vagrant rsync-auto](http://docs.vagrantup.com/v2/cli/rsync-auto.html).


## Running with Docker

Everything can be run using the `docker-compose.yml`, but with a few changes.

### restore a database backup

Download a database dump from the S3 backups. Then, use `psql` to import the database dump into a the running postgres container.

Example:

```
psql -h localhost -U otm -d otm <~/20210308.dump
```

There are a few changes that need to be made:
* The volumes for nginx need to be updated. Both nginx and otm-core need to share a local volume for the static and media directories
* The otm-core and otm-tiler hostname in the nginx configs should be updated to localhost
* Running this requires localstack to be setup
* Each repository under otm-vagrant (otm-core, otm-ecoservice, otm-tiler) needs to have the Dockerfile built with otm-[name]:1.0
* Create a symlink for otm-core called otm_core
* Create a symlink for otm-tiler called otm_tiler
