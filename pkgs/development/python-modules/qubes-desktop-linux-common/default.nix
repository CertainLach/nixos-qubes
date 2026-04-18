{
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  distutils,
  pyxdg,
  qubes-core-admin-client,
  qubes-imgconverter,
  graphicsmagick,
}:
let
  version = "4.2.15";
  src = fetchFromGitHub {
    owner = "QubesOS";
    repo = "qubes-desktop-linux-common";
    rev = "refs/tags/v${version}";
    hash = "sha256-mB4Z3c1p/LocpSmXn4Oa45/039kjvtSY1Xobgf90ivM=";
  };
in
buildPythonPackage {
  inherit version src;
  pname = "qubes-desktop-linux-common";
  format = "setuptools";

  nativeBuildInputs = [
    graphicsmagick
    distutils
  ];

  propagatedBuildInputs = [
    pyxdg
    qubes-core-admin-client
    qubes-imgconverter
    # Wanted at runtime
    setuptools
  ];

  postInstall = ''
    make install $makeFlags
  '';

  makeFlags = [ "DESTDIR=$(out)" ];
}
