Linux: LXC Verification
=======================

System Requirements
-------------------

+ [Vagrant](http://www.vagrantup.com/downloads.html)
+ [VirtualBox](https://www.virtualbox.org/wiki/Downloads)

Getting Started
---------------

```
$ make up
```

Worklog
-------

```
$ time sudo root_password=root lxc-create -n fedora20 -t fedora


real    6m30.281s
user    0m12.618s
sys     0m18.468s
```

```
$ sudo vi /var/lib/lxc/fedora20/config
lxc.utsname = fedora20
lxc.tty = 6
#lxc.pts = 1024
lxc.network.type = veth
lxc.network.flags = up
lxc.network.link = lxcbr0
lxc.network.name = eth0
lxc.network.mtu = 1472
lxc.network.hwaddr = fe:e5:14:60:81:18
lxc.rootfs = /var/lib/lxc/fedora20/rootfs
lxc.rootfs.mount = /var/lib/lxc/fedora20/rootfs

#lxc.mount.entry = devpts /lxc/private/${ctid}/dev/pts                devpts  gid=5,mode=620  0 0
lxc.mount.entry = proc   /var/lib/lxc/fedora20/rootfs/proc                   proc    defaults        0 0
lxc.mount.entry = sysfs  /var/lib/lxc/fedora20/rootfs/sys                    sysfs   defaults        0 0

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
```

```
$ sudo rsync -avx /lib/modules /var/lib/lxc/fedora20/rootfs/lib/
```

```
$ sudo lxc-start -n fedora20 -d -l DEBUG -o /var/log/lxc/fedora20.log
```

License
-------

[Beerware](http://en.wikipedia.org/wiki/Beerware) license.

If we meet some day, and you think this stuff is worth it, you can buy me a beer in return.
