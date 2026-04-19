{
  lib,
  rustPlatform,
  fetchFromGitHub,
  python3,
  qubes-linux-utils,
}:
let
  version = "1.1.0";
  qubes-core-qrexec = python3.pkgs.qubes-core-qrexec;
  src = fetchFromGitHub {
    owner = "QubesOS";
    repo = "qubes-notification-proxy";
    rev = "refs/tags/v${version}";
    hash = "sha256-AIASRswGiPUQwazhoblovv75fUkFTF8xiNyt1VLCoK4=";
  };
in
rustPlatform.buildRustPackage {
  inherit version src;
  pname = "qubes-notification-proxy";

  cargoLock.lockFile = ./Cargo.lock;

  buildInputs = [ qubes-linux-utils ];

  # Tests require dbus/qubes runtime
  doCheck = false;

  postPatch = ''
    ln -s ${./Cargo.lock} Cargo.lock

    substituteInPlace src/qubes-notification-agent.service \
      --replace-fail "/usr/bin/qrexec-client-vm" "${qubes-core-qrexec.domU}/bin/qrexec-client-vm" \
      --replace-fail "/usr/bin/qubes-notification-proxy-client" "$out/bin/qubes-notification-proxy-client"
  '';

  postInstall = ''
    # Rename binaries to match qubes naming
    mv $out/bin/notification-proxy-server $out/bin/qubes-notification-proxy-server
    mv $out/bin/notification-proxy-client $out/bin/qubes-notification-proxy-client

    # RPC handler (dom0 side)
    install -d $out/etc/qubes-rpc $out/etc/qubes/rpc-config
    ln -s $out/bin/qubes-notification-proxy-server $out/etc/qubes-rpc/qubes.Notifications
    echo "wait-for-session=1" > $out/etc/qubes/rpc-config/qubes.Notifications

    # Systemd user service (domU side)
    install -d $out/lib/systemd/user $out/lib/systemd/user-preset
    install -m 0644 src/qubes-notification-agent.service $out/lib/systemd/user/
    install -m 0644 src/90-qubes-notification-agent.preset $out/lib/systemd/user-preset/
  '';

  meta = {
    description = "Notification proxy for Qubes OS";
    homepage = "https://github.com/QubesOS/qubes-notification-proxy";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [
      lach
      sigmasquadron
    ];
    platforms = lib.platforms.linux;
  };
}
