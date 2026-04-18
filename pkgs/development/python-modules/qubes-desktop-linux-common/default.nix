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
  version = "4.4.0";
  src = fetchFromGitHub {
    owner = "QubesOS";
    repo = "qubes-desktop-linux-common";
    rev = "refs/tags/v${version}";
    hash = "sha256-je7xK9O8Z8xFZhOWreOrvGhP9sFtKzyKsegAxlo6UE8=";
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
