#!/usr/bin/env sh

update() {
  nix-update -F "$@" -vr "v(.*)"
}

# Normal
update "qubes-artwork"
update "qubes-core-admin-linux"
update "qubes-core-agent-linux"
update "qubes-core-qubesdb"
update "qubes-core-vchan-xen"
update "qubes-desktop-linux-kde"
update "qubes-gui-common"
update "qubes-gui-daemon"
update "qubes-linux-utils"
update "qubes-manager"
update "qubes-seabios"

# Python
update "qubes-app-linux-usb-proxy"
update "qubes-core-admin"
update "qubes-core-admin-client"
# update "qubes-core-qrexec"
update "qubes-desktop-linux-common"
update "qubes-desktop-linux-manager"

# Nix-update downgrades those D:
# https://github.com/Mic92/nix-update/issues/271
nix-update -F "qubes-core-qrexec" -vr "v(.*)" --version v4.3.10

# Needs special care:
# qubes-core-libvirt - patches nixpkgs libvirt
# qubes-vmm-stubdom-linux - needs to be updated manually, or have updateScript
# qubes-vmm-xen - xen has its own update infrastructure
