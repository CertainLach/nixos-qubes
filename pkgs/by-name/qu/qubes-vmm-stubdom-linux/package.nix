# Qubes standard stubdom is too hard to build using nix infrastructure.
# In the future, it will be better to replace it with NixOS based stubdom, or maybe based on dockerTools build system?
{
  lib,
  fetchurl,
  stdenv,
  rpmextract,
}:
let
  qubesVersion = "4.3";
  fedoraVersion = "41";
  version = "4.3.1-1";
  stubdom = fetchurl {
    url = "https://ftp.qubes-os.org/repo/yum/r${qubesVersion}/current-testing/dom0/fc${fedoraVersion}/rpm/xen-hvm-stubdom-linux-${version}.fc${fedoraVersion}.x86_64.rpm";
    hash = "sha256-OHyUTB3AwVFdmLOwUSNmNCI1lmMPh1PzHd/H5r2oTN4=";
  };
  stubdom-full = fetchurl {
    url = "https://ftp.qubes-os.org/repo/yum/r${qubesVersion}/current-testing/dom0/fc${fedoraVersion}/rpm/xen-hvm-stubdom-linux-full-${version}.fc${fedoraVersion}.x86_64.rpm";
    hash = "sha256-qMHZ5ouw62GoaQqWeEcph1ddJ5o4kcQJp9TuiW81R2s=";
  };
in
stdenv.mkDerivation {
  name = "qubes-vmm-stubdom-linux";
  src = null;
  unpackPhase = "true";
  buildPhase = "true";

  nativeBuildInputs = [ rpmextract ];

  installPhase = ''
    mkdir $out
    rpmextract ${stubdom}
    rpmextract ${stubdom-full}
    mv usr/libexec $out/
  '';

  meta = {
    description = "Qubes xen stubdom";
    homepage = "https://qubes-os.org";
    # TODO: Figure out licensing for this abomination.
    # This package includes linux kernel and some other packages,
    # so it should be licensed under gpl2Only AND XXX
    #
    # For now mark it as unfreeRedistributable, to prevent those
    # binaries from being cached on hydra (hydra does not cache redistributable packages
    # yet)
    license = lib.licenses.unfreeRedistributable;
    maintainers = with lib.maintainers; [
      lach
      sigmasquadron
    ];
    platforms = lib.platforms.linux;
    sourceProvenance = [
      lib.sourceTypes.binaryNativeCode
    ];
  };
}
