#!/bin/sh

template_name=$1
src_dir=$template_name

if ! test -f "$src_dir/template.conf"; then
  echo "invalid template dir"
fi

dest_dir=/var/lib/qubes/vm-templates/$template_name
mkdir -p "$dest_dir"

if ls "$dest_dir/apps/*.directory" "$dest_dir/apps/*.desktop" >/dev/null 2>&1; then
  echo "--> Removing previous menu shortcuts..."
  xdg-desktop-menu uninstall --mode system \
    "$dest_dir/apps/*.directory" "$dest_dir/apps/*.desktop"
fi

echo "--> Processing root.img... (this might take a while)"
cat "$src_dir"/root.img.part.* | tar --sparse -xf - -C "$dest_dir"
