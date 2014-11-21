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
