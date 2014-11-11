otm2-vagrant
============

Vagrant files and scripts for setting up a local testing and development instance of OTM2

__NOTE:__ This repository is intended _only_ for development and testing.  It is not intended for setting up a production OTM2 server.

To get started, do the following steps:

 - Install [Vagrant](http://www.vagrantup.com/) and [VirtualBox](https://www.virtualbox.org/)
 - Clone this repository
 - Run the script `get-repos.sh`
 - Run the command `vagrant up`
 
This will give you a working installation of OTM2, but without any maps.

To create a map do the following steps:

 - Create a user from your web browser (the URL should be `localhost:6060`). The email will be written to a file in `/usr/local/otm/emails/` inside the VM
 - SSH into the vagrant VM with `vagrant ssh`
 - Read the email with your user activation link (`cat /usr/local/otm/emails/*`) and activate the user by pasting the URL in it into your browser
 - Source the virtual environment using `source /usr/local/otm/env/bin/activate`
 - Change to the opentreemap directory using `cd /usr/local/otm/app/opentreemap`
 - Create a tree map using the `create_instance` management command, passing the username you created above. For example, to create a tree map with name "Philadelphia", url name `philly`, and admin user "sue", centered at longitude -75.1 and latitude 40.0:

```sh
    ./manage.py create_instance Philadelphia --url_name=philly --user=sue --center=-75.1,40.0
```

For further help on how to use `create_instance`, run `./manage.py create_instance -h`

## Windows

To run on Windows you must install [Cygwin](https://www.cygwin.com) (including `rsync` and `openssh`) and start a Unix shell like `bash` to run the install scripts.

On Windows the OTM source code is shared with the virtual machine via a one-way `rsync` from Windows host to Ubuntu guest. When you update source code files you must run `vagrant rsync` from your Windows Unix shell. See also [vagrant rsync-auto](http://docs.vagrantup.com/v2/cli/rsync-auto.html).
