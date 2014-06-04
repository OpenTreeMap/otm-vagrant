# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "precise64"

  # for selenium tests
  config.ssh.forward_x11 = true

  config.vm.network :forwarded_port, guest: 80, host: 6060

  config.vm.synced_folder "OTM2", "/usr/local/otm/app"
  config.vm.synced_folder "OTM2-tiler", "/usr/local/tiler"
  config.vm.synced_folder "ecobenefits", "/usr/local/ecoservice"

  config.vm.provision :shell, :path => "OTM2/scripts/bootstrap.sh"
  config.vm.provision :shell, :path => "bootstrap.sh"

  config.vm.provider :virtualbox do |vb, override|
    override.vm.box_url = "http://files.vagrantup.com/precise64.box"
    vb.customize ["modifyvm", :id, "--memory", 2048, "--cpus", "2"]
  end
  config.vm.provider :lxc do |lxc, override|
    override.vm.box_url = "http://bit.ly/vagrant-lxc-precise64-2013-10-23"
    lxc.customize "cgroup.memory.limit_in_bytes", '2048M'
  end
end
