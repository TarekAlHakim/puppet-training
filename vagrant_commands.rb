########
Vagrant.configure("2") do |config|
  config.vm.provision "shell", path: "script.sh"
end

Vagrant.configure("2") do |config|
  config.vm.provision "shell", path: "https://example.com/provisioner.sh"
end 
########

Vagrant.configure("2") do |config|
  # This configuration applies to all virtual machines
  # Set the box to Ubuntu 14.04 64-bit OS
  config.vm.box = "ubuntu/trusty64"

  # Map port 8080 on the host to port 80 on the virtual machine
  # http://localhost:8080 should open the default Apache page on the virtual machine
  config.vm.network "forwarded_port", guest: 80, host: 8080

  # This configuration is applied only to the virtual machine named “web”
  config.vm.define "web" do |web|
    # LAN IP address for the virtual machine
    web.vm.network :private_network, ip: "192.168.33.10"
  end

  # This part is applied only to the second virtual machine named “db”
  config.vm.define "db" do |db|
    # LAN IP address for the virtual machine
    db.vm.network :private_network, ip: "192.168.33.11"
  end
end 