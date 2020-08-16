# POC for building up a monitoring system

This is a POC for installing and configuring Elastic Stack with Ansible. The repository also contains a Vagrant 
configuration which provides a basic Hyper-V VM for testing.

Please, note that this project is only a POC and not intended to provide a fully functional production grade setup.

For achieving my goals (mainly learn Asnible) I used the awesome repositories of geerlingguy 
(https://github.com/geerlingguy?tab=repositories), hence the similarities in our solutions.

Every constructive comment and commit is welcommed!

## Prerequisites

This project uses:
* Vagrant (version >= 2.2.7);
* Hyper-V for virtualization.

#### Important notes

* Vagrant commands must be executed with elevated user privileges.
* The setup is not compatible with VPN due to conflicts in networking.

## Setting up the test environment

In the `Vagrantfile` hyperv provider is configured. To boot the VMs, execute the following command in the root folder:
```
vagrant up
```

#### Plugin installation

There are additional plugins might be configured in the `Vagrantfile`, and in case they are not installed yet, 
the first execution of vagrant commands will ask for input to installing it.
```
Vagrant has detected project local plugins configured for this
project which are not installed.

  vagrant-reload
Install local plugins (Y/N) [N]: Y
```

In the example above Vagrant asks if `vagrant-reload` plugin should be installed. Select Yes, it might be necessary to 
execute again the original vagrant command.

#### Special configurations

In case of Hyper-V provider special a configuration step is necessary as currently Vagrant does not support static IP 
by default (see: https://www.vagrantup.com/docs/hyperv/limitations.html).

Interaction is necessary during the setup process of Hyper-V VM, you will be prompt to select an approproate switch:

```
elastic-vm: Please choose a switch to attach to your Hyper-V instance.
elastic-vm: If none of these are appropriate, please open the Hyper-V manager
elastic-vm: to create a new virtual switch.
elastic-vm:
elastic-vm: 1) Default Switch
elastic-vm: 2) VagrantNAT
elastic-vm:
elastic-vm: What switch would you like to use? 1
```

In this case __always the 'Default Switch' should be selected__ (option 1 in the example above).

The applied workaround for static IP in the Vagrantfile will create the `VagrantNAT` switch (if it doesn't exist) just
before the prompt for selection, but for the succesfull install the 'Default Switch' must be selected. Eventually, in a
later step the VM will be automaticly reconfigured to use the `VagrantNAT` switch with the known IP address.

This configuration only required at the first execution of `vagrant up` command.

#### Default configurations

* IP: 10.0.99.2
* hostname: elastic-vm
* vCPU: 4
* memory: 4096GB/8192GB (min/max)

#### Check status

```
vagrant status
```

#### Access the VM

Convenient command for accessing the VM:

```
vagrant ssh
``` 

#### Stopt the VM

```
vagrant halt
```

#### Troubleshooting

Configure the Vagrant loglevel with the following variable:

```
VAGRANT_LOG=debug
```

If vagrant stuck at boot time after previous successful boots, it might help if the setup is destroyed and
the .vagrant folder deleted.

#### Destroy the test setup

To clean up (remove VM, VirtualSwitch and network configuraiton), execute the following:

```
vagrant destroy -f
```

The command above forcibly removes the VMs, without the -f flag, Vagrant asks for confirmation.

#### Further docs

Please, visit the official site: https://www.vagrantup.com/docs

## Ansible playbooks

Ansible and few additional useful package are installed at the first `vagrant up`.

Vagrant syncronizes the root project folder (parent folder of `Vagrantfile`) once after the VM was booted. To trigger
synchronization manually (e.g. for syncing the changes in the ansible resources), use the following command:

```
vagrant rsync
```

#### Elastic stack installation

The project provides a single playbook `monitoring-setup.yml` that is responsible for installing and configuring the
Elastic components. To execute this playbook either you need to ssh into the VM or you can utilize the provided
`ansible-playbook` helper script.

The playbook will install the following applications and required packages:
* Java8 OpenJDK
* Elasticsearch
* Kibana
* Logstash
* APM-server
* httpd

#### Verification

By default, Kibana should be available on the following url:

https://10.0.99.2/monitoring

The components health can be checked by the following commands (with root privilege):

```
# Elasticsearch
curl --cacert /etc/elasticsearch/certs/ca.crt https://10.0.99.2:9200/_cluster/health?pretty

# Kibana
curl --cacert /etc/kibana/certs/ca.crt https://10.0.99.2:5601/monitoring/api/status

# Logstash
curl http://127.0.0.1:9600/?pretty

# APM-server
systemctl status apm-server
```

#### ILM policy

TBD

