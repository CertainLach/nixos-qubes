{
  stdenv,
  patsh,
  rpmextract,
  fakeroot,
  e2fsprogs,
  rsync,
  python3,
}:
let
  inherit (python3.pkgs) qubes-core-admin-client;
in

stdenv.mkDerivation {
  name = "nixos-qubes-tools";
  version = "0.1.0";

  src = ./bin;

  buildInputs = [
    rpmextract
    qubes-core-admin-client
    fakeroot
    e2fsprogs
    rsync
  ];

  nativeBuildInputs = [
    patsh
  ];

  installPhase = ''
    		mkdir -p $out/bin
    		cp ./* $out/bin/
    		for name in nixos-qubes-install-{kernel,template}-rpm; do
    			patsh -f $out/bin/$name -s ${builtins.storeDir}
    		done
    	'';
}
