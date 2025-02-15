{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:
let
  version = "4.3.0";
  src = fetchFromGitHub {
    owner = "QubesOS";
    repo = "qubes-gui-common";
    rev = "refs/tags/v${version}";
    hash = "sha256-piFnt0v/FdmTiMwXd3hYjAMAKoo4cWsRlHbNk+voRR0=";
  };
in
stdenvNoCC.mkDerivation {
  inherit version src;
  name = "qubes-gui-common";

  buildPhase = "true";

  installPhase = ''
    mkdir -p $out
    cp -r include $out/
  '';

  meta = {
    description = "Qubes GUI protocol definitions";
    homepage = "https://qubes-os.org";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.all;
    maintainers = with lib.maintainers; [
      lach
      sigmasquadron
    ];
  };
}
