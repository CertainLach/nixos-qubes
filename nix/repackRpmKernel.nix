{
  stdenv,
  rpmextract,
  fakeroot,
  e2fsprogs,
  util-linux,
  zstd,
  attr,
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
      attr
      kmod
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
      # Image must contain the version-named subdirectory, not bare files.
      mkdir -p imgroot
      cp -a "$moduledir" imgroot/

      # Generate module index files (modules.dep, modules.alias, etc.)
      depmod -b imgroot ${kernelVersion}.qubes.${fedoraVersion}.${stdenv.hostPlatform.parsed.cpu.name}

      # Set SELinux labels so modules are accessible under enforcing SELinux in VMs
      find imgroot -exec setfattr -n security.selinux \
        -v "system_u:object_r:modules_object_t:s0" {} \;

      # Match upstream qubes-prepare-vm-kernel: ext3 with minimal features,
      # create at 768M then shrink with resize2fs.
      truncate -s 768M modules.img
      fakeroot mkfs.ext3 -q -F \
        -Enum_backup_sb=0,root_owner=0:0 \
        -d imgroot modules.img
      e2fsck -pDf modules.img >/dev/null || true
      resize2fs -fM modules.img >/dev/null
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
