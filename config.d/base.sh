#!/bin/bash
#
# requires:
#  bash
#
set -e
set -o pipefail
set -x

# Do some changes ...

for i in ifdown-macvlan ifup-macvlan; do
  curl -fsSkL https://raw.githubusercontent.com/larsks/initscripts-macvlan/master/${i} -o /etc/sysconfig/network-scripts/${i}
  chmod +x /etc/sysconfig/network-scripts/${i}
done

##

cat <<EOS > /etc/sysconfig/network-scripts/ifcfg-lxcbr0
DEVICE=lxcbr0
TYPE=Bridge
BOOTPROTO=static
IPADDR=172.16.254.1
NETMASK=255.255.255.0
ONBOOT=yes
EOS

#ifup lxcbr0

##

# ip-forward
cat <<EOS > /etc/sysctl.d/enable-ip-forward.conf
net.ipv4.ip_forward = 1
EOS
sysctl -p

##

cat <<'EOS' > /etc/sysconfig/iptables
*nat
:PREROUTING ACCEPT [0:0]
:POSTROUTING ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
-A POSTROUTING -o eth0 -s 172.16.254.0/24 -j MASQUERADE
COMMIT

*filter
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
COMMIT
EOS

systemctl disable firewalld.service
systemctl enable  iptables.service
systemctl start   iptables.service

systemctl disable NetworkManager.service
systemctl stop    NetworkManager.service
systemctl enable  network.service
#systemctl start   network.service

#service network restart

reboot
