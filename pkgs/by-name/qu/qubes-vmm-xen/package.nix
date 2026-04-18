{
  lib,
  fetchpatch,
  fetchgit,
  xen,
  qubes-seabios,
  qubes-vmm-stubdom-linux,
  python3Packages,
  replaceVars,
  # Dependencies for 0002-scripts-external-executable-calls.patch
  bridge-utils,
  coreutils,
  diffutils,
  drbd,
  gawk,
  gnugrep,
  gnused,
  inetutils,
  iproute2,
  iptables,
  kmod,
  libnl,
  multipath-tools,
  nbd,
  openiscsi,
  openvswitch,
  psmisc,
  systemd,
  util-linux,
  which,
}:
let
  inherit (lib) genAttrs getExe getExe';

  version = "4.19.4";
  revision = "7";

  # Substitutions for 0002-scripts-external-executable-calls.patch
  # Mirrors scriptDeps from nixpkgs xen package
  scriptDeps =
    let
      mkTools = pkg: tools: genAttrs tools (tool: getExe' pkg tool);
    in
    (genAttrs [
      "CONFIG_DIR" "CONFIG_LEAF_DIR" "LIBEXEC_BIN"
      "XEN_LOG_DIR" "XEN_RUN_DIR" "XEN_SCRIPT_DIR"
      "qemu_xen_systemd" "sbindir"
    ] (_: null))
    // (mkTools coreutils [
      "basename" "cat" "cp" "cut" "dirname" "head"
      "ls" "mkdir" "mktemp" "readlink" "rm" "seq" "sleep" "stat"
    ])
    // (mkTools drbd [ "drbdadm" "drbdsetup" ])
    // (mkTools gnugrep [ "egrep" "grep" ])
    // (mkTools iproute2 [ "bridge" "ip" "tc" ])
    // (mkTools iptables [ "arptables" "ip6tables" "iptables" ])
    // (mkTools kmod [ "modinfo" "modprobe" "rmmod" ])
    // (mkTools libnl [ "nl-qdisc-add" "nl-qdisc-delete" "nl-qdisc-list" ])
    // (mkTools util-linux [ "flock" "logger" "losetup" "prlimit" ])
    // {
      awk = getExe' gawk "awk";
      brctl = getExe bridge-utils;
      diff = getExe' diffutils "diff";
      ifconfig = getExe' inetutils "ifconfig";
      iscsiadm = getExe' openiscsi "iscsiadm";
      killall = getExe' psmisc "killall";
      multipath = getExe' multipath-tools "multipath";
      nbd-client = getExe' nbd "nbd-client";
      ovs-vsctl = getExe' openvswitch "ovs-vsctl";
      sed = getExe gnused;
      systemd-notify = getExe' systemd "systemd-notify";
      which = getExe which;
    };

  qubesPatches = import ./patches.nix {
    inherit fetchpatch version revision;
  };
  qubesPatchList = lib.lists.flatten (
    with qubesPatches;
    [
      EFI_WORKAROUNDS
      BACKPORTS
      SECURITY_FIXES
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

    # Qubes patches first, then nixpkgs build-infra patches (copied locally) to avoid conflicts
    patches = qubesPatchList ++ [
      ./0001-makefile-efi-output-directory.patch
      (replaceVars ./0002-scripts-external-executable-calls.patch scriptDeps)
    ];

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
