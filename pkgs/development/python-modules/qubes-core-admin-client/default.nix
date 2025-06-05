{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  qubes-core-qrexec,
  qubes-core-qubesdb,
  qubes-gui-daemon,
  tqdm,
  pyxdg,
  pkgs,
  lxml,
  pyaml,
  xcffib,
  xlib,
  socat,
  replaceVars,
  bash,
  distutils,
  setuptools,
  # Used by qvm-template. Required for proper initial setup, will not work on NixOS, however.
  rpm,
}:

let
  inherit (pkgs) hwdata scrypt;
  inherit (pkgs.xorg) xrandr xhost;

  version = "4.3.17";
  src = fetchFromGitHub {
    owner = "QubesOS";
    repo = "qubes-core-admin-client";
    rev = "refs/tags/v${version}";
    hash = "sha256-n10FxpFJU2AeawGnuMmqgBO7GVI6CSGY++zBcoafJsA=";
  };
in
buildPythonPackage {
  inherit version src;
  pname = "qubes-core-admin-client";
  format = "other";

  patches = [
    (replaceVars ./0001-refactor-template-paths.patch {
      inherit
        scrypt
        hwdata
        xrandr
        xhost
        ;
      # TODO: Depends on agent-linux, meaning this path is located on remote machine.
      # Lets assume paranoid backup/restore won't work for now.
      qfile_unpacker = "/var/empty";
      qrexec_dom0 = qubes-core-qrexec.dom0;
      qrexec_domU = qubes-core-qrexec.domU;
      # TODO: package windows tools
      qubes_windows_tools = "/var/empty";
      qubes_guid = qubes-gui-daemon;
    })
    ./0002-refactor-fixup-paths.patch
  ];

  postPatch = ''
    # It makes zero sense, but those symlinks are installed by other package in QubesOS!
    # https://github.com/QubesOS/qubes-core-admin/blob/fca5ec7f3bf3c567676384b39c29b6163bef7531/Makefile#L182-L188
    # Can't just use ln in postInstall, because wrappers break everything.
    pushd qubesadmin/tools
    cp qvm_device.py qvm_usb.py
    cp qvm_device.py qvm_pci.py
    popd
  '';

  nativeBuildInputs = [
    distutils
    setuptools
  ];

  propagatedBuildInputs = [
    tqdm
    pyxdg
    rpm
    lxml
    pyaml
    xcffib
    xlib
    qubes-core-qubesdb

    # Script dependencies
    bash
    socat
  ];

  pythonImportsCheck = [ "qubesadmin" ];

  makeFlags = [
    "DESTDIR=$(out)"
    "PYTHON_PREFIX_ARG=--prefix=."
  ];

  meta = {
    description = "Qubesd client library";
    homepage = "https://qubes-os.org";
    license = with lib.licenses; [ gpl2Plus ];
    maintainers = with lib.maintainers; [
      lach
      sigmasquadron
    ];
    platforms = lib.platforms.all;
  };
}
