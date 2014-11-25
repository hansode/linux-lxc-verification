#!/bin/bash
#
# requires:
#  bash
#
set -e
set -o pipefail
set -x

function render_lxc_conf() {
  local ctid=${1:-101}

  cat <<EOS
lxc.utsname = ct${ctid}.$(hostname)
lxc.tty = 6
#lxc.pts = 1024
lxc.network.type = veth
lxc.network.flags = up
lxc.network.link = lxcbr0
lxc.network.name = eth0
lxc.network.mtu = 1472
#lxc.network.hwaddr = 52:54:00:$(LANG=C LC_ALL=C date +%H:%M:%S)
lxc.rootfs = ${rootfs_path}
lxc.rootfs.mount = ${rootfs_path}

lxc.mount.entry = proc   ${rootfs_path}/proc                   proc    defaults        0 0
lxc.mount.entry = sysfs  ${rootfs_path}/sys                    sysfs   defaults        0 0

# /dev/null and zero
lxc.cgroup.devices.allow = c 1:3 rwm
lxc.cgroup.devices.allow = c 1:5 rwm

# consoles
lxc.cgroup.devices.allow = c 5:1 rwm
lxc.cgroup.devices.allow = c 5:0 rwm
lxc.cgroup.devices.allow = c 4:0 rwm
lxc.cgroup.devices.allow = c 4:1 rwm

# /dev/{,u}random
lxc.cgroup.devices.allow = c 1:9 rwm
lxc.cgroup.devices.allow = c 1:8 rwm
lxc.cgroup.devices.allow = c 136:* rwm
lxc.cgroup.devices.allow = c 5:2 rwm

# rtc
lxc.cgroup.devices.allow = c 254:0 rwm

# kvm
lxc.cgroup.devices.allow = c 232:10 rwm

# net/tun
lxc.cgroup.devices.allow = c 10:200 rwm

# nbd
lxc.cgroup.devices.allow = c 43:* rwm
EOS
}

function install_lxc_conf() {
  local ctid=${1:-101}
  local lxc_conf_path=/var/lib/lxc/${ctid}/config

  render_lxc_conf  ${ctid} > ${lxc_conf_path}
  chmod 644 ${lxc_conf_path}
}

function render_ifcfg() {
  local ctid=${1:-101}

  cat <<EOS
DEVICE=eth0
TYPE=Ethernet
ONBOOT=yes
BOOTPROTO=static
BROADCAST=172.16.254.255
GATEWAY=172.16.254.1
IPADDR=172.16.254.${ctid}
NETMASK=255.255.255.0
MTU=1472
EOS
}

function install_ifcfg() {
  local ifcfg_path=${rootfs_path}/etc/sysconfig/network-scripts/ifcfg-eth0

  render_ifcfg ${ctid} > ${ifcfg_path}
  chmod 644 ${ifcfg_path}
}

## main

LANG=C
LC_ALL=C

declare ctid=${1:-101}
declare rootpass=${rootpass:-root}

readonly rootfs_path=/var/lib/lxc/${ctid}/rootfs

### create container

root_password=${rootpass} lxc-create -n ${ctid} -t fedora
sed -i s,^HOSTNAME=.*,HOSTNAME=ct${ctid}.$(hostname), ${rootfs_path}/etc/sysconfig/network
echo ct${ctid}.$(hostname) > ${rootfs_path}/etc/hostname

### post-install/execscript

mkdir -p ${rootfs_path}/lib/modules
rsync -ax /lib/modules/$(uname -r) ${rootfs_path}/lib/modules/

mount -o bind /proc ${rootfs_path}/proc
#chroot ${rootfs_path} bash -c -e "yum install -y qemu-kvm qemu-img"
chroot ${rootfs_path} bash -c -e "echo root:${rootpass} | chpasswd"
umount ${rootfs_path}/proc

###

install_lxc_conf ${ctid}
install_ifcfg    ${ctid}

### start container

lxc-start -n ${ctid} -d -l DEBUG -o /var/log/lxc/${ctid}.log

### add device

lxc-device -n ${ctid} add /dev/kvm
lxc-device -n ${ctid} add /dev/net/tun
