# -*- mode: ruby -*-
# vi: set ft=ruby :

# Source: http://stackoverflow.com/questions/11784109/detecting-operating-systems-in-ruby
require 'rbconfig'
def os
  @os ||= (
    host_os = RbConfig::CONFIG['host_os']
    case host_os
    when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
      :windows
    when /darwin|mac os/
      :macosx
    when /linux/
      :linux
    when /solaris|bsd/
      :unix
    else
      raise Error::WebDriverError, "unknown os: #{host_os.inspect}"
    end
  )
end

Vagrant.configure("2") do |config|
  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "precise64"

  # for selenium tests
  config.ssh.forward_x11 = true

  config.vm.network :forwarded_port, guest: 80, host: 6060

  if os != :windows
    config.vm.synced_folder "OTM2", "/usr/local/otm/app"
    config.vm.synced_folder "OTM2-tiler", "/usr/local/tiler"
    config.vm.synced_folder "ecobenefits", "/usr/local/ecoservice"

  else
    # For Windows hosts, work around limitation that symbolic links don't work in shared folders
    if not File.exist?('.vagrant/machines/default/virtualbox/id')
      # VM not set up yet -- rsync everything
      config.vm.synced_folder ".", "/vagrant", type: "rsync", rsync__exclude: ".git/"
      config.vm.synced_folder "OTM2", "/usr/local/otm/app", type: "rsync", rsync__exclude: [".git/", "node_modules", "opentreemap/opentreemap/settings/local_settings.py"]

    else
      # VM already set up.
      # Exclude "configs" folder to avoid clobbering nginx configuration.
      config.vm.synced_folder ".", "/vagrant", type: "rsync", rsync__exclude: [".git/", "configs/"]

      # Use a true shared folder for "opentreemap" (for convenience) (works because it uses no symlinks)
      config.vm.synced_folder "OTM2/opentreemap", "/usr/local/otm/app/opentreemap"
      if not File.exist?('OTM2/opentreemap/opentreemap/settings/local_settings.py')
        # local_settings.py was created on the guest, but we need to create it on the host since we're sharing its folder.
        FileUtils.cp('configs/usr/local/otm/app/opentreemap/opentreemap/settings/local_settings.py', 'OTM2/opentreemap/opentreemap')
      end
    end

    config.vm.synced_folder "OTM2-tiler", "/usr/local/tiler", type: "rsync", rsync__exclude: [".git/", "node_modules", "settings.json"]
    config.vm.synced_folder "ecobenefits", "/usr/local/ecoservice", type: "rsync", rsync__exclude: ".git/"
  end

  config.vm.provision :shell, :path => "OTM2/scripts/bootstrap.sh"
  config.vm.provision :shell, :path => "bootstrap.sh"

  config.vm.provider :virtualbox do |vb, override|
    override.vm.box_url = "http://files.vagrantup.com/precise64.box"
    vb.customize ["modifyvm", :id, "--memory", 2048, "--cpus", "2"]
  end
  config.vm.provider :lxc do |lxc, override|
    override.vm.box = "fgrehm/precise64-lxc"
    lxc.backingstore = 'none'
    lxc.customize "cgroup.memory.limit_in_bytes", '2048M'
  end
end
