{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:
let
  version = "4.3.1";
  src = fetchFromGitHub {
    owner = "QubesOS";
    repo = "qubes-gui-common";
    rev = "refs/tags/v${version}";
    hash = "sha256-RDB2tS+vLXu7RwA6Ng4TekIubzIKtuQK8ALRGjsXmcY=";
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
