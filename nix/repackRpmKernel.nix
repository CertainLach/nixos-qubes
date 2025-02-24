{
  stdenv,
  rpmextract,
  fakeroot,
  e2fsprogs,
  util-linux,
  zstd,
}:
{
  kernelSrc,
  modulesSrc,
  kernelVersion,
  fedoraVersion,
}:
let
  version = "${kernelVersion}.${fedoraVersion}";
  modulesImg = stdenv.mkDerivation {
    inherit version;
    pname = "qubes-kernel-modules.img";
    src = modulesSrc;
    nativeBuildInputs = [
      fakeroot
      rpmextract
      e2fsprogs
      util-linux
      zstd
    ];
    unpackPhase = "rpmextract $src";
    # TODO: Shrink image after creation.
    # TODO: Use makeDiskImage for that?
    buildPhase = ''
      moduledir=lib/modules/${kernelVersion}.qubes.${fedoraVersion}.${stdenv.hostPlatform.parsed.cpu.name}
      if ! test -f "$moduledir/modules.builtin"; then
        echo "modules dir with the specified name is not found in modules rpm"
        ls -lah lib/modules/
        exit 1
      fi
      truncate -s 512M modules.img
      fakeroot mkfs.ext4 -d "$moduledir" -F modules.img
    '';
    installPhase = ''
      mv modules.img $out
    '';
  };
in
stdenv.mkDerivation {
  inherit version;
  pname = "qubes-kernel";
  src = kernelSrc;
  nativeBuildInputs = [
    rpmextract
  ];
  unpackPhase = "rpmextract $src";
  installPhase = ''
    kerneldir=var/lib/qubes/vm-kernels/${kernelVersion}.${fedoraVersion}
    if ! test -f "$kerneldir/vmlinuz"; then
      echo "kernel with specified name is not found in kernel rpm"
      exit 1
    fi
    mkdir "$out"
    mv "$kerneldir"/* "$out/"
    ln -s ${modulesImg} "$out/modules.img"
  '';
}
