{
  lib,
  stdenv,
  fetchFromGitHub,
  python3,
}:
let
  inherit (python3.pkgs) qubes-core-admin-client;
  version = "6.2.0-3";
  src = fetchFromGitHub {
    owner = "QubesOS";
    repo = "qubes-desktop-linux-kde";
    rev = "refs/tags/v${version}";
    hash = "sha256-s4wGPECjfyHgjuDadvmDCj3g+de/4zVSWaqdNirEFiY=";
  };
in
# NOTE: Only window colorschema generator is packaged here, original
# also has such things as changing default panel configuration, which is not wanted.
stdenv.mkDerivation {
  inherit version src;
  pname = "qubes-desktop-linux-kde";

  postPatch = ''
    substituteInPlace qubes-generate-color-palette.desktop \
      --replace-fail "Exec=" "Exec=$out/libexec/"
    substituteInPlace qubes-generate-color-palette \
      --replace-fail "#!/usr/bin/python3" "Exec=#!/usr/bin/env python3"
  '';

  nativeBuildInputs = [
    python3.pkgs.wrapPython
  ];

  buildPhase = "true";

  installPhase = ''
    mkdir -p $out/{libexec,etc/xdg/autostart}
    cp qubes-generate-color-palette $out/libexec/
    cp qubes-generate-color-palette.desktop $out/etc/xdg/autostart/
    wrapPythonProgramsIn $out/libexec ${qubes-core-admin-client}
  '';

  meta = {
    description = "Qubes GUI KDE utilities";
    homepage = "https://qubes-os.org";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.all;
    maintainers = with lib.maintainers; [
      lach
      sigmasquadron
    ];
  };
}
