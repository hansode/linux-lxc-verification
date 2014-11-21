# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "hansode/fedora-20-x86_64"

  config.vm.provider :virtualbox do |v, override|
   # Disable the base shared folder, guest additions are unavailable.
   #override.vm.synced_folder ".", "/vagrant", disabled: true
    v.gui = true
   #v.customize ["modifyvm", :id, "--memory", "1024"]

   # [Vagrant / virtualbox DNS 10.0.2.3 not working](http://serverfault.com/questions/453185/vagrant-virtualbox-dns-10-0-2-3-not-working)
   #
   # Enabling DNS proxy in NAT mode
   # > VBoxManage modifyvm "VM name" --natdnsproxy1 on
   # Using the host's resolver as a DNS proxy in NAT mode
   # > VBoxManage modifyvm "VM name" --natdnshostresolver1 on
   #
   v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
  end

  config.vm.provider :vmware_workstation do |v, override|
   # Disable the base shared folder, guest additions are unavailable.
    override.vm.synced_folder ".", "/vagrant", disabled: true
   #v.gui = true
   #v.vmx["memsize"]  = "2048"
   #v.vmx["numvcpus"] = "2"
    v.vmx["vhv.enable"] = "TRUE"

   ## eth1
   #v.vmx["ethernet1.present"]        = "TRUE"
   #v.vmx["ethernet1.connectionType"] = "hostonly"
   #v.vmx["ethernet1.virtualDev"]     = "e1000"
   #v.vmx["ethernet1.wakeOnPcktRcv"]  = "FALSE"
  end

  config.ssh.forward_agent = true

  config.vm.provision "shell", path: "bootstrap.sh"     # Bootstrapping: package installation (phase:1)
  config.vm.provision "shell", path: "config.d/base.sh" # Configuration: node-common          (phase:2)

 #2.times.each { |i|
 #  name = sprintf("node%02d", i + 1)
 #  config.vm.define "#{name}" do |node|
 #    node.vm.hostname = "#{name}"
 #    node.vm.provision "shell", path: "config.d/#{node.vm.hostname}.sh" # Configuration: node-specific (phase:2.5)
 #   end
 #}
end
