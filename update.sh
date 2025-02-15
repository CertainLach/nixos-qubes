#!/usr/bin/env sh

update() {
  nix-update -F "$@" -vr "v(.*)"
}

# Normal

# Python

# Needs special care:
