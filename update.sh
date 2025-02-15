#!/usr/bin/env sh

update() {
  nix-update -F "$@" -vr "v(.*)"
}

# Normal
update "qubes-artwork"
update "qubes-core-agent-linux"
update "qubes-core-qubesdb"
update "qubes-core-vchan-xen"
update "qubes-gui-common"
update "qubes-gui-daemon"
update "qubes-linux-utils"
update "qubes-seabios"

# Python

# Needs special care:
# qubes-vmm-stubdom-linux - needs to be updated manually, or have updateScript
# qubes-vmm-xen - xen has its own update infrastructure
