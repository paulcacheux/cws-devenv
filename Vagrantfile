# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/jammy64"
  config.vm.synced_folder "~/dd/", "/home/vagrant/dd/"
  config.vm.network "private_network", type: "dhcp"
  config.disksize.size = '50GB'

  config.vm.provider "virtualbox" do |vb|
      vb.memory = 4096
      vb.cpus = 4
  end

  config.vm.provision :docker
end
