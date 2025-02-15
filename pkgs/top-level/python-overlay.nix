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
  qubes-vmm-xen = toPythonModule (
    pkgs.qubes-vmm-xen.override {
      python3Packages = self;
    }
  );
}
