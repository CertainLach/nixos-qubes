self: super:
let
  inherit (self)
    callPackage
    pkgs
    python
    toPythonModule
    ;
in
{
  qubes-app-linux-usb-proxy = callPackage ../development/python-modules/qubes-app-linux-usb-proxy { };

  qubes-core-admin = callPackage ../development/python-modules/qubes-core-admin { };

  qubes-core-admin-client = callPackage ../development/python-modules/qubes-core-admin-client { };

  qubes-core-libvirt = self.libvirt.override {
    libvirt = pkgs.qubes-core-libvirt;
    # FIXME: Override maintainers
  };

  qubes-core-qrexec = callPackage ../development/python-modules/qubes-core-qrexec { };

  qubes-core-qubesdb =
    (pkgs.qubes-core-qubesdb.override {
      inherit python;
      withPython = true;
    }).pythonModule;

  qubes-desktop-linux-common =
    callPackage ../development/python-modules/qubes-desktop-linux-common
      { };

  qubes-desktop-linux-manager =
    callPackage ../development/python-modules/qubes-desktop-linux-manager
      { };

  qubes-imgconverter =
    (pkgs.qubes-linux-utils.override {
      inherit python;
      withPython = true;
    }).imgconverter;

  qubes-vmm-xen = toPythonModule (
    pkgs.qubes-vmm-xen.override {
      python3Packages = self;
    }
  );
}
