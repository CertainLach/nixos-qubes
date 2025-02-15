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
  qubes-core-qubesdb =
    (pkgs.qubes-core-qubesdb.override {
      inherit python;
      withPython = true;
    }).pythonModule;

  qubes-vmm-xen = toPythonModule (
    pkgs.qubes-vmm-xen.override {
      python3Packages = self;
    }
  );
}
