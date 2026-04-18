{
  lib,
  stdenv,
  fetchFromGitHub,
  qubes-vmm-xen,
}:
let
  version = "4.2.8";
  src = fetchFromGitHub {
    owner = "QubesOS";
    repo = "qubes-core-vchan-xen";
    rev = "refs/tags/v${version}";
    hash = "sha256-8pwVGYhaHTcvSHlF2wS+XyiHon8q5tmO72YDnoyfZVk=";
  };
in
stdenv.mkDerivation {
  inherit version src;
  pname = "qubes-core-vchan-xen";

  buildInputs = [ qubes-vmm-xen.dev ];

  buildFlags = [ "all" ];

  makeFlags = [
    "DESTDIR=/"
    "PREFIX=/"
    "LIBDIR=$(out)/lib"
    "INCLUDEDIR=$(out)/include"
  ];

  # This flag needs to be enabled for Xen > 1.18.
  env.CFLAGS = "-DHAVE_XC_DOMAIN_GETINFO_SINGLE";

  meta = with lib; {
    description = "Libraries required for the higher-level Qubes daemons and tools";
    homepage = "https://qubes-os.org";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      lach
      sigmasquadron
    ];
    platforms = platforms.linux;
  };
}
