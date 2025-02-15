{
  settings.global.excludes = [
    "pkgs/by-name/qu/qubes-core-libvirt/series.conf"

    "*.adoc"
  ];

  programs.nixfmt.enable = true;
  programs.shfmt.enable = true;
}
