# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.require_version '>= 2.2.7'

node_ip = "10.0.99.2"
node_name = "elastic-vm"
gateway_ip = "10.0.99.1"
gateway_prefixLength = 8
gateway_prefix = "10.0.99.0"
switch_name = "VagrantNAT"
network_name = "VagrantNATNetwork"

Vagrant.configure("2") do |config|

  config.vm.boot_timeout = 300
  
  config.vagrant.plugins = ['vagrant-reload']
  
  config.vm.define "#{node_name}" do |machine|
  
    machine.vm.box = "centos/7"
    machine.vm.box_version = "1905.1"
    machine.vm.box_check_update = false
    
    machine.vm.hostname = "#{node_name}"
    
    machine.vm.synced_folder ".", "/vagrant", type: "rsync"
    
    machine.vm.network "private_network", ip: "#{node_ip}"
    
    machine.vm.provider "hyperv" do |hv|
      hv.vmname = "#{node_name}"
      hv.maxmemory = 8192
      hv.memory = 4096
      hv.cpus = 4

      hv.enable_virtualization_extensions = true
      hv.linked_clone = true
    end
    
    machine.trigger.before :up do |trigger|
      trigger.info = "Generating ssh key for Ansible if does not exist..."
      trigger.run = {
        privileged: "true",
        powershell_elevated_interactive: "true",
        path: "./scripts/generate-ssh.ps1"
      }
    end
    
    machine.trigger.before :up do |trigger|
      trigger.info = "Creating '#{switch_name}' Virtual Switch if it does not exist..."
      trigger.run = {
        privileged: "true",
        powershell_elevated_interactive: "true",
        path: "./scripts/hyperv-switch-create-nat.ps1",
        args: [
          "-SwitchName", "#{switch_name}",
          "-IPAddress", "#{gateway_ip}",
          "-PrefixLength", "#{gateway_prefixLength}",
          "-NetName", "#{network_name}",
          "-NetMask", "#{gateway_prefix}"
        ]
      }
    end
    
    # Assign Hyper-V switch to VM
    machine.trigger.before :reload do |trigger|
      trigger.info = "Setting Hyper-V switch to '#{switch_name}' to allow static IP..."
      trigger.run = {
        privileged: "true",
        powershell_elevated_interactive: "true",
        path: "./scripts/hyperv-switch-set-nat.ps1",
        args: [
          "-VMName", "#{node_name}",
          "-SwitchName", "#{switch_name}"
        ]
      }
    end
    
    machine.trigger.after :destroy do |trigger|
      trigger.info = "Removing '#{switch_name}' Virtual Switch if it exists..."
      trigger.run = {
        privileged: "true",
        powershell_elevated_interactive: "true",
        path: "./scripts/hyperv-switch-remove-nat.ps1",
        args: [
          "-SwitchName", "#{switch_name}",
          "-IPAddress", "#{gateway_ip}",
          "-PrefixLength", "#{gateway_prefixLength}",
          "-NetName", "#{network_name}",
          "-NetMask", "#{gateway_prefix}"
        ]
      }
    end
    
    # Configures the static IP on Guest machine.
    machine.vm.provision "shell",
      path: "./scripts/configure-static-ip.sh",
      args: [ "#{node_ip}", "#{gateway_ip}" ]

    # Reload the provisioner to activate the changes.
    # This requires the vagrant-reload plugin to be installed.
    machine.vm.provision :reload
  
    # Copy private key to Ansible controller
    machine.vm.provision "shell", inline: <<-SHELL
      echo "Copying ssh private key onto master node..."
      cp -R /vagrant/.ssh /home/vagrant/
      chmod 400 /home/vagrant/.ssh/id_rsa
      chown vagrant:vagrant /home/vagrant/.ssh/id_rsa
    SHELL
    
    # Add key to authorized_keys
    machine.vm.provision "shell", inline: <<-SHELL
      echo "Authorizing ssh key..."
      cat /vagrant/.ssh/id_rsa.pub >> /home/vagrant/.ssh/authorized_keys
    SHELL
    
    machine.vm.provision "packages-install", type: "shell", inline: <<-SHELL
      echo "Installing additional packages..."
      sudo yum install -y net-tools unzip
    SHELL
    
    # Install Ansible
    machine.vm.provision "ansible-install", type: "shell", inline: <<-SHELL
      echo "Installing Ansible and required packages..."
      rpm --import http://download.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-7
      rpm --import http://mirror.centos.org/centos/7/os/x86_64/RPM-GPG-KEY-CentOS-7
      yum -y -q install epel-release
      yum -y install sshpass ansible
      yum -y install policycoreutils-python setroubleshoot
    SHELL
   
  end

end