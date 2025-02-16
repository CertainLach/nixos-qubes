{
  lib,
  fetchpatch,
  buildXenPackage,
  qubes-seabios,
  qubes-vmm-stubdom-linux,
  xen,
  python3Packages,
}:
let
  version = "4.19.1";
  revision = "2";

  qubesPatches = import ./patches.nix {
    inherit fetchpatch version revision;
  };
  qubesPatchList = lib.lists.flatten (
    with qubesPatches;
    [
      EFI_WORKAROUNDS
      BACKPORTS
      UPSTREAMABLE_PATCHES
      QUBES_SPECIFIC_PATCHES
      OTHERS
    ]
  );
in
(buildXenPackage.override
  {
    inherit python3Packages;
    systemSeaBIOS = qubes-seabios;
  }
  {
    pname = "qubes-vmm-xen";
    inherit version;
    upstreamVersion = version;
    vendor = "qubes";

    withSeaBIOS = true;
    withOVMF = true;
    withIPXE = false;

    rev = "ccf400846780289ae779c62ef0c94757ff43bb60";
    hash = "sha256-s0eCBCd6ybl+kLtXCC6E1sk++w7txXn/B/Cg5acQFfY=";
    patches = qubesPatchList ++ [
      (fetchpatch {
        url = "https://lore.kernel.org/xen-devel/e2caa6648a0b6c429349a9826d8fbc4338222482.1733766758.git.andrii.sultanov@cloud.com/raw";
        hash = "sha256-JC1ueXuC1Jdi2gtUsjOHmTeEx56zjotMMLde5vBonxc=";
      })
    ];

    meta = {
      inherit (xen.meta) license mainProgram platforms;
      description = "Qubes component: vmm-xen";
      longDescription = ''
        Qubes OS' modified version of the Xen Project Hypervisor.
        Contains dozens of Qubes-specific patches, and is intended to power a Qubes OS Domain 0.

        Use with `qemu_qubes`.
      '';
      homepage = "https://qubes-os.org";
      downloadPage = "https://github.com/QubesOS/qubes-vmm-xen";
      maintainers = with lib.maintainers; [
        lach
        sigmasquadron
      ];
    };
  }
).overrideAttrs
  (oldAttrs: {
    postInstall =
      oldAttrs.postInstall
      + ''
        ln -sf ${qubes-vmm-stubdom-linux}/libexec/xen/boot/qemu-stubdom-linux{-full,}-{kernel,rootfs} \
          $out/libexec/xen/boot/
      '';
  })
