# Vagrant setup with No Internet for Puppet development. # 
Vagrant.require_plugin "vagrant-windows"

# Variables #
domain_name = ".puppet.vm" 
win2012_box = "opentable/win-2012r2-standard-amd64-nocm"
win2012_url = "https://app.vagrantup.com/opentable/boxes/win-2012r2-standard-amd64-nocm"
centos7_box = "geerlingguy/centos7" 
centos7_url = "https://app.vagrantup.com/geerlingguy/boxes/centos7"

win_servers = {
  :web2 => { :hostname => 'web2', :ip => '10.10.10.11', :rdp_port => 3390, :winrm_port => 5986},
  :web3 => { :hostname => "web3", :ip => '10.10.10.12', :rdp_port => 3391, :winrm_port => 5987},
  :db1 =>  { :hostname => "db1",  :ip => '10.10.10.13', :rdp_port => 3393, :winrm_port => 5988}
}

centos_servers = {
    :gitlab => {:hostname =>  "gitlab", :ip => '192.168.0.14'},
    :mom =>    {:hostname =>     "mom", :ip => '10.10.10.15'},
    :web0 =>   {:hostname =>    "web0", :ip => '10.10.10.16'},
    :web1 =>   {:hostname =>    "web1", :ip => '10.10.10.17'},
    :db0 =>    {:hostname =>     "db0", :ip => '10.10.10.18'},  
    :lb0 =>    {:hostname =>     "lb0", :ip => '10.10.10.19'},
    :mon0 =>   {:hostname =>    "mon0", :ip => '10.10.10.20'}
}

Vagrant.configure("2") do |global_config|
    #global_config.vm.network :private_network, :ip => "192.168.0.1", :adapter => 2, :auto_config => true
    
    win_servers.each_pair do |name, options|
      global_config.vm.define name do |config|
        rdp_port = options[:rdp_port]
        winrm_port = options[:winrm_port]
        hostname = options[:hostname]
        domain = domain_name
        config.vm.guest = :windows
        config.vm.box = win2012_box
        #config.vm.box_url = win2012_url
        #config.winrm.username = "vagrant"
        #config.winrm.password = "vagrant"
        config.vm.hostname = hostname + 'domain' 
        config.vm.network :forwarded_port, guest: 3389, host: rdp_port
        config.vm.network :forwarded_port, guest: 5985, host: winrm_port
        config.vm.network :private_network, ip: options[:ip]
        #config.vm.synced_folder "./repo", "C:\\users\\Tarek\\Documents\\vagrant\\"
        config.vm.provider :virtualbox do |v|
          v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
          v.customize ["modifyvm", :id, "--memory", 1024]
          v.customize ["modifyvm", :id, "--name", hostname]
          v.customize ["modifyvm", :id, "--cpuexecutioncap", 40]
        end
      end
    end
 
  centos_servers.each_pair do |name, options|
    global_config.vm.define name do |config|
      config.vm.guest = :linux
      config.vm.hostname = options[:hostname] + ".puppet.vm" 
      config.vm.network :private_network, ip: win_servers[:ip]
      config.vm.box_url = "geerlingguy/centos7"
      config.vm.box = "centos7"
      config.vm.synced_folder "./", "/var/www", owner: "www-data", group: "www-data" 
      # config.vm.provider :virtualbox do |v|
      #   v.customize ["modifyvm", :id, "--natdnshostresolver1", "off"]
      #   v.customize ["modifyvm", :id, "--cpuexecutioncap", 40]
      # end
    end
  end  

  
end
