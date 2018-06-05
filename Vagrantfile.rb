###################################################################
# Vagrant setup with No Internet for Puppet development. # 
###################################################################

#############
# Variables #
#############
Domain   = 'puppet.vm'
Centos_image = "bento/ubuntu-16.04"
Windows_image = "windows/#####"

nodes = [
  { :hostname => 'gitlab', :ip => '10.10.10.11' },
  { :hostname => 'mom',    :ip => '10.10.10.12' },
  { :hostname => 'web0',   :ip => '10.10.10.13' },
  { :hostname => 'web1',   :ip => '10.10.10.14' },
  { :hostname => 'web2',   :ip => '10.10.10.15' },
  { :hostname => 'web3',   :ip => '10.10.10.16' },
  { :hostname => 'db0',    :ip => '10.10.10.17' },
  { :hostname => 'db1',    :ip => '10.10.10.18' },
  { :hostname => 'lb0',    :ip => '10.10.10.19' },
  { :hostname => 'mon0',   :ip => '10.10.10.20' },
]

####################
# Global VM configuration #
####################
Vagrant.configure("2") do |config|
  config.vm.network :hostonly, :type => "10.10.10.1", :auto_config => true
  
  nodes.each do |node|
    config.vm.define node[:hostname] do |nodeconfig|
      nodeconfig.ssh.insert_key = false
      nodeconfig.vm.hostname = node[:hostname] + ".puppet.vm"
      nodeconfig.vm.network :private_network, ip: node[:ip]
      memory = node[:ram] ? node[:ram] : 1024;
      nodeconfig.vm.provider :virtualbox do |vb|
          vb.customize [
          "modifyvm", :id,
          "--cpuexecutioncap", "50",
          "--memory", memory.to_s,
        ]
      end
    end

####################
# Node configurations #
####################
  config.vm.define "gitlab", primary: true do |gitlab|
    gitlab.vm.box = "centos7"
    gitlab.vm.box_url = "generic/centos7"
    nodeconfig.vm.box = "puppetlabs/centos-7.2-64-puppet"
    end
  end

  config.vm.define "web02", autostart: false do |web02|
    web02.vm.box = "centos7"
    web02.vm.hostname = 'web02'
    web02.vm.box_url = "generic/centos7"
    end
  end

  config.vm.define "db" do |db|
    db.vm.box = "centos7"
    db.vm.hostname = 'db'
    db.vm.box_url = "ubuntu/centos7"

    db.vm.network :private_network, ip: "192.168.56.102"
    db.vm.network :forwarded_port, guest: 22, host: 10222, id: "ssh"

    db.vm.provider :virtualbox do |v|
      v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      v.customize ["modifyvm", :id, "--memory", 512]
      v.customize ["modifyvm", :id, "--name", "db"]
    end
  end

end
###############
##############
  
  
  nodes.each do |node|
    config.vm.define node[:hostname] do |nodeconfig|
      nodeconfig.ssh.insert_key = false
      nodeconfig.vm.box = "generic/centos7"
      nodeconfig.vm.hostname = node[:hostname] + ".puppet.vm"
      nodeconfig.vm.network :private_network, ip: node[:ip]

      memory = node[:ram] ? node[:ram] : 4096;
      nodeconfig.vm.provider :virtualbox do |vb|
          vb.customize [
          "modifyvm", :id,
          "--cpuexecutioncap", "70",
          "--memory", memory.to_s,
        ]

bootstrap_script = <<-EOF
    echo 10.10.10.11 node1 node1.puppet.vm >> /etc/hosts
		echo 10.10.10.12 node2 node2.puppet.vm >> /etc/hosts
		echo 10.10.10.13 node3 node3.puppet.vm >> /etc/hosts
		echo 10.10.10.14 node4 node4.puppet.vm >> /etc/hosts
    echo 10.10.10.15 master master.puppet.vm >> /etc/hosts
    sudo iptables -I INPUT -p all -j ACCEPT
		sudo nmcli connection reload
		sudo systemctl restart network.service
		sudo systemctl disable firewalld
                   EOF
            config.vm.provision :shell, :inline => bootstrap_script


      end
    end


  ############################################################################################
  # Workaround for Vagrant bug still present in Vagrant 1.8.5                                #
  # (http://stackoverflow.com/questions/32518591/centos7-with-private-network-lost-fixed-ip) #
  ############################################################################################
  

  
  ######################
  # Puppet provisioner #
  ###################### 
  config.vm.provision :puppet do |puppet|
    # General config
    puppet.environment_path = "environments"
    puppet.environment = "production"
    puppet.module_path = "environments/production/modules"

    # Hiera config
    puppet.hiera_config_path = "hiera/hiera.yaml"
    puppet.working_directory = "/tmp/vagrant-puppet"

    # Custom facts
    puppet.facter = {
      "customfact" => "TestCustomFact"
    }
  end
  
end
end
