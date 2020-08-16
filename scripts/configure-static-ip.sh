#!/bin/sh

echo "Setting static IP address $1 and gateway $2 for Hyper-V VM..."

cat << EOF > /etc/sysconfig/network-scripts/ifcfg-eth0
DEVICE=eth0
BOOTPROTO=none
ONBOOT=yes
PREFIX=24
IPADDR=$1
GATEWAY=$2
DNS1=213.46.246.53
EOF

# Be sure NOT to execute "systemctl restart network" here, so the changes take
# effect on reboot instead of immediately, which would disconnect the provisioner.