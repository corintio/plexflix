Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/xenial64"
  config.vm.network "forwarded_port", guest: 2015, host: 2015
  config.vm.network "forwarded_port", guest: 8000, host: 8000
  config.vm.network "forwarded_port", guest: 32400, host: 32400
  config.vm.network "forwarded_port", guest: 32400, host:32400, protocol:"udp"
  config.vm.network "forwarded_port", guest: 32469, host:32469 
  config.vm.network "forwarded_port", guest: 32469, host:32469, protocol:"udp"
  config.vm.network "forwarded_port", guest: 5353, host:5353, protocol:"udp"
  config.vm.network "forwarded_port", guest: 1900, host:1900, protocol:"udp"
  config.vm.network "private_network", ip: "192.168.33.10"
  config.vm.provision "shell", inline: <<-SHELL
    test -e /usr/bin/python || (apt-get update && apt-get install -y python-minimal python-pip)
  SHELL
end
