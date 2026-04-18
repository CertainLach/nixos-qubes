{
  lib,
  fetchpatch,
  fetchgit,
  xen,
  qubes-seabios,
  qubes-vmm-stubdom-linux,
  python3Packages,
}:
let
  version = "4.19.4";
  revision = "7";

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
(xen.override
  {
    inherit python3Packages;
    seabios-qemu = qubes-seabios;

    withSeaBIOS = true;
    withOVMF = true;
    withIPXE = false;
  }
).overrideAttrs
  (oldAttrs: {
    pname = "qubes-vmm-xen";
    inherit version;
    vendor = "qubes";
    upstreamVersion = version;

    patches =
      builtins.filter (
        p:
        let
          name = builtins.baseNameOf p;
        in
        lib.hasPrefix "0001-makefile" name || lib.hasPrefix "0002-scripts" name
      ) oldAttrs.patches
      ++ qubesPatchList;

    src = fetchgit {
      url = "https://xenbits.xenproject.org/git-http/xen.git";
      rev = "c2ece6c994a236e9ba51c9ec99085ae99347d552";
      hash = "sha256-V30e0V7dsu3FMR7H+UE+DeCYbfLV9FV9wr0MnoUKCNk=";
    };
  
    postInstall =
      oldAttrs.postInstall
      + ''
        ln -sf ${qubes-vmm-stubdom-linux}/libexec/xen/boot/qemu-stubdom-linux{-full,}-{kernel,rootfs} \
          $out/libexec/xen/boot/
      '';
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
  })
