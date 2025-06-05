{
  buildPythonPackage,
  fetchFromGitHub,
  gettext,
  qubes-core-admin-client,
  qubes-core-qrexec,
  pygobject3,
  gtk3,
  gobject-introspection,
  wrapGAppsHook3,
}:
let
  version = "4.3.13";
  src = fetchFromGitHub {
    owner = "QubesOS";
    repo = "qubes-desktop-linux-manager";
    rev = "refs/tags/v${version}";
    hash = "sha256-pBl+qfnxwTRoXKPT9PATdLPGCFDsltBa3i5m/igj10w=";
  };
in

# TODO: use /lib/qubes/qubes-device-agent-autostart
buildPythonPackage {
  inherit version src;
  pname = "qubes-desktop-linux-manager";
  format = "setuptools";

  nativeBuildInputs = [
    gettext
    wrapGAppsHook3
    gobject-introspection
  ];

  propagatedBuildInputs = [
    qubes-core-admin-client
    qubes-core-qrexec
    pygobject3
    gtk3
  ];

  postInstall = ''
    make install DESTDIR=$out
    mv $out/usr/bin/* $out/bin/
    mv $out/usr/lib/* $out/lib/
    mv $out/usr/share $out/
    rm -d $out/usr/{bin,lib,}
  '';

  # buildFlags = ["all"];
}
