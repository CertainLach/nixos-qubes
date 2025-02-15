{
  lib,
  libvirt_10_5,
  fetchFromGitHub,
  qubes-vmm-xen,
}:

let
  inherit (lib) optionalString assertMsg;
  libvirt = libvirt_10_5;

  versionPatches = "10.5.0";
  versionSuffix = "2";
  patches = fetchFromGitHub {
    owner = "QubesOS";
    repo = "qubes-core-libvirt";
    rev = "refs/tags/v${versionPatches}-${versionSuffix}";
    hash = "sha256-8es8maDdvly4k1CMXGlckYUADyMcywIpFTZyDs0PS7g=";
  };
in

assert assertMsg (libvirt.version == "10.5.0")
  "libvirt was updated to ${libvirt.version}, qubes-core-libvirt patchset was intended to be used with ${versionPatches}";

(libvirt.override {
  enableXen = true;
  xen = qubes-vmm-xen;
}).overrideAttrs
  (oldAttrs: {
    pname = "qubes-core-libvirt";
    version = "${versionPatches}-${versionSuffix}";

    # series-qubes.conf in patches repo is outdated, this list is generated from file listing
    # in the original repo.
    # TODO: updateScript is required.
    postPatch =
      ''
        cp ${./series.conf} series-qubes.conf
        ${patches}/apply-patches series-qubes.conf ${patches}
      ''
      + optionalString (oldAttrs ? postPatch) oldAttrs.postPatch;

    meta = {
      description = "libvirt with qubes patches applied";
      homepage = "https://qubes-os.org";
      # TODO: Figure out derivative work license here.
      license = lib.licenses.lgpl2Plus;
      platforms = lib.platforms.unix;
      maintainers = with lib.maintainers; [
        lach
        sigmasquadron
      ];
    };
  })
