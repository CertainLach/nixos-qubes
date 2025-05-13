{
  lib,
  stdenv,
  rpmextract,
  fakeroot,
  e2fsprogs,
  rsync,
  python3,
}:
let
  inherit (python3.pkgs) qubes-core-admin-client buildPythonApplication pydantic setuptools;
in

buildPythonApplication {
  name = "nixos-qubes-tools";
  version = "0.1.0";
  format = "pyproject";

  # TODO: Filter
  src = ./.;

  buildInputs = [
    rpmextract
    fakeroot
    e2fsprogs
    rsync
    setuptools
  ];

  dependencies = [
    qubes-core-admin-client
    pydantic
  ];

  meta = {
    description = "Qubes declarative state reconciler";
    license = lib.licenses.mit;
    sourceProvenance = [ lib.sourceTypes.fromSource ];
    maintainers = [ lib.maintainers.lach ];
    mainProgram = "nixpkgs-qubes-reconcile";
  };
}
