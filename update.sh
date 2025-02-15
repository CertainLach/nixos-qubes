#!/usr/bin/env sh

update() {
  nix-update -F "$@" -vr "v(.*)"
}

# Normal

# Python

# Needs special care:
# qubes-vmm-stubdom-linux - needs to be updated manually, or have updateScript
