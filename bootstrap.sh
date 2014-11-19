#!/bin/bash
#
# requires:
#  bash
#
set -e
set -o pipefail
set -x

function yum() {
  $(type -P yum) --disablerepo=updates "${@}"
}

# Add installation packages ...
addpkgs="
 lxc
 lxc-templates
 lxc-extra
"

if [[ -n "$(echo ${addpkgs})" ]]; then
  yum install -y --enablerepo=updates ${addpkgs}
fi
