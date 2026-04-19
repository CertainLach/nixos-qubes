{
  lib,
  rpmextract,
  fakeroot,
  e2fsprogs,
  rsync,
  curl,
  rpm,
  attr, # setfattr for SELinux labels
  kmod, # depmod for module index
  makeWrapper,
  python3,
}:
let
  inherit (python3.pkgs) qubes-core-admin-client buildPythonApplication pydantic setuptools;
  runtimePath = lib.makeBinPath [
    rpmextract
    fakeroot
    e2fsprogs
    rsync
    curl
    rpm # rpmkeys for signature verification
    attr # setfattr for SELinux labels
    kmod # depmod for module index
  ];
in

buildPythonApplication {
  name = "nixos-qubes-tools";
  version = "0.1.0";
  format = "pyproject";

  # TODO: Filter
  src = ./.;

  nativeBuildInputs = [
    makeWrapper
    setuptools
  ];

  dependencies = [
    qubes-core-admin-client
    pydantic
  ];

  postInstall = ''
    for script in nixos-qubes-install-template-rpm nixos-qubes-install-kernel-rpm nixos-qubes-install-template-url nixos-qubes-install-kernel-url; do
      install -m 0755 src/$script $out/bin/$script
      wrapProgram $out/bin/$script --prefix PATH : ${runtimePath}
    done
  '';

  meta = {
    description = "Qubes declarative state reconciler";
    license = lib.licenses.mit;
    sourceProvenance = [ lib.sourceTypes.fromSource ];
    maintainers = [ lib.maintainers.lach ];
    mainProgram = "nixpkgs-qubes-reconcile";
  };
}
