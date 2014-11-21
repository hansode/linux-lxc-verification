#!/bin/bash
#
# requires:
#  bash
#
set -e
set -o pipefail
set -x

LANG=C
LC_ALL=C

ctid=${1:-101}
rootpass=${rootpass:-root}

rootfs_path=/var/lib/lxc/${ctid}/rootfs

### create container

root_password=${rootpass} lxc-create -n ${ctid} -t fedora

### render/install lxc.conf

cat <<EOS > /var/lib/lxc/${ctid}/config
lxc.utsname = ct${ctid}.$(hostname)
lxc.tty = 6
#lxc.pts = 1024
lxc.network.type = macvlan
lxc.network.flags = up
lxc.network.macvlan.mode = bridge
lxc.network.link = eth0
lxc.network.name = eth0
lxc.network.mtu = 1472
lxc.network.hwaddr = fe:e5:14:60:81:18
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

### post-install/execscript

[[ -d ${rootfs_path}/lib/modules ]] || mkdir -p ${rootfs_path}/lib/modules
rsync -ax /lib/modules/$(uname -r) ${rootfs_path}/lib/modules/

mount -o bind /proc ${rootfs_path}/proc
#chroot ${rootfs_path} bash -c -e "yum install -y qemu-kvm qemu-img"
chroot ${rootfs_path} bash -c -e "echo root:${rootpass} | chpasswd"
umount ${rootfs_path}/proc

### start container

lxc-start -n ${ctid} -d -l DEBUG -o /var/log/lxc/${ctid}.log

### add device

lxc-device -n ${ctid} add /dev/kvm
lxc-device -n ${ctid} add /dev/net/tun
