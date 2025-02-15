{
  lib,
  fetchFromGitHub,
  python3,
  qt6,
  gobject-introspection,
  wrapGAppsHook3,
}:
let
  inherit (python3.pkgs)
    buildPythonApplication
    pyqt6
    setuptools
    qubes-core-admin-client
    qubes-desktop-linux-manager
    qasync
    pyaml
    lxml
    ;

  version = "4.3.8-1";

  src = fetchFromGitHub {
    owner = "QubesOS";
    repo = "qubes-manager";
    rev = "refs/tags/v${version}";
    hash = "sha256-j3r4UhDEKFPN1+lw1DONZaeLlL2xl/MdWgKuOPAoOok=";
  };
in
buildPythonApplication {
  inherit version src;
  pname = "qubes-manager";

  nativeBuildInputs = [
    setuptools
    pyqt6
    qt6.qttools
    qt6.wrapQtAppsHook
    wrapGAppsHook3
    gobject-introspection
  ];

  dependencies = [
    pyqt6
    qubes-core-admin-client
    qubes-desktop-linux-manager
    qasync
    pyaml
    lxml
    qt6.qtwayland
  ];

  preBuild = ''
    make ui res translations python $makeFlags
  '';

  installTargets = [ "python_install" ];

  postInstall = ''
    make install $makeFlags
    mv $out/usr/* $out
    rm -d $out/usr
  '';

  makeFlags = [
    "DESTDIR=$(out)"
    "LRELEASE_QT6=lrelease"
  ];
  pythonImportsCheck = [ "qubesmanager" ];

  meta = {
    description = "Qubes management UI";
    homepage = "https://qubes-os.org";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [
      lach
      sigmasquadron
    ];
    platforms = lib.platforms.linux;
  };
}
