{
  lib,
  stdenv,
  fetchFromGitHub,
  icu,
  pkg-config,
  qubes-vmm-xen,
  patsh,
  qubes-core-qubesdb,
  kmod,
  graphicsmagick,

  withPython ? false,
  python ? null,
}:
let
  inherit (lib) optionalAttrs;

  version = "4.3.7";
  src = fetchFromGitHub {
    owner = "QubesOS";
    repo = "qubes-linux-utils";
    rev = "refs/tags/v${version}";
    hash = "sha256-+RGa1mpHAlxwdr/5Tw0rDXlQ4tfeHQ92m/mgvy733d4=";
  };

in
stdenv.mkDerivation {
  inherit version src;
  pname = "qubes-linux-utils";

  # imgconverter is built in separate derivation
  postPatch = ''
    substituteInPlace Makefile \
      --replace-fail "\$(MAKE) -C imgconverter all" "" \
      --replace-fail "\$(MAKE) -C imgconverter install" ""
    substituteInPlace qmemman/*.service \
      --replace-fail "ExecStart=/usr/sbin/meminfo-writer" "ExecStart=$out/bin/meminfo-writer"
  '';

  nativeBuildInputs = [
    pkg-config
    patsh
  ];

  buildInputs = [
    icu.dev
    qubes-vmm-xen.dev

    qubes-core-qubesdb
    kmod
  ];

  postInstall = ''
    mv $out/usr/lib/systemd $out/lib/
    rm -d $out/usr/{lib,}

    substituteInPlace $out/lib/udev/rules.d/99-qubes-{usb,block}.rules \
      --replace-fail '/usr/lib/qubes/' "$out/libexec/qubes/"

    for hook in block-add-change block-remove usb-add-change usb-remove; do
      substituteInPlace $out/libexec/qubes/udev-$hook \
        --replace-quiet "/sbin/modprobe" "/bin/modprobe"
      patsh -f $out/libexec/qubes/udev-$hook -s ${builtins.storeDir}
    done
  '';

  makeFlags = [
    "DESTDIR=$(out)"
    "LIBDIR=/lib"
    "SCRIPTSDIR=/libexec/qubes"
    "SYSLIBDIR=/lib"
    "INCLUDEDIR=/include"
    "SBINDIR=/bin"
    "CFLAGS=-DUSE_XENSTORE_H"
  ];

  meta = {
    description = "Qubes common linux integration hooks";
    homepage = "https://qubes-os.org";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [
      lach
      sigmasquadron
    ];
  };
}
