{
  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/master";
    };
    # Qubes has outdated libvirt version
    nixpkgs-libvirt_10_5 = {
      url = "github:NixOS/nixpkgs/e0464e47880a69896f0fb1810f00e0de469f770a";
    };
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    shelly = {
      url = "github:CertainLach/shelly";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } (
      { self, ... }:
      let
        inherit (inputs.nixpkgs.lib) composeExtensions;
      in
      {
        imports = [ inputs.shelly.flakeModule ];
        systems = [ "x86_64-linux" ];

        flake.overlays.qubesPackages =
          composeExtensions
            (composeExtensions (import ./pkgs/top-level/overlay.nix) (
              import "${inputs.nixpkgs}/pkgs/top-level/by-name-overlay.nix" ./pkgs/by-name
            ))
            (self: _: { libvirt_10_5 = inputs.nixpkgs-libvirt_10_5.legacyPackages.${self.system}.libvirt; });
        flake.overlays.default = self.overlays.qubesPackages;

        flake.nixosModules.qubes = {
          config.nixpkgs.overlays = [ self.overlays.default ];
          imports = [ ./nixos/modules/virtualisation/qubes ];
          _file = ./flake.nix;
        };
        flake.nixosModules.default = self.nixosModules.qubes;

        perSystem =
          {
            lib,
            pkgs,
            system,
            ...
          }:
          let
            treefmt = (inputs.treefmt-nix.lib.evalModule pkgs ./treefmt.nix).config.build;
          in
          {
            _module.args.pkgs = import inputs.nixpkgs {
              inherit system;
              overlays = [
                self.overlays.qubesPackages
              ];
            };

            packages = {
              inherit (pkgs)
                qubes-artwork
                qubes-core-admin-linux
                qubes-core-agent-linux
                qubes-core-libvirt
                qubes-core-qubesdb
                qubes-core-vchan-xen
                qubes-desktop-linux-kde
                qubes-gui-common
                qubes-gui-daemon
                qubes-linux-utils
                qubes-manager
                qubes-seabios
                qubes-vmm-stubdom-linux
                qemu_qubes
                ;
              inherit (pkgs.python3.pkgs)
                qubes-app-linux-usb-proxy
                qubes-core-admin
                qubes-core-admin-client
                qubes-core-qrexec
                qubes-desktop-linux-common
                qubes-desktop-linux-manager
                qubes-imgconverter
                qubes-vmm-xen
                ;

              # Those packages are both python3Package and normal package, choosen one is above.
              # inherit (pkgs) qubes-vmm-xen;
              # inherit (pkgs.python3.pkgs) qubes-core-libvirt qubes-core-qubesdb;
            };

            shelly.shells.default = {
              packages = [
                pkgs.nix-update
              ];
            };
            formatter = treefmt.wrapper;
            checks.formatting = treefmt.check self;
          };
      }
    );
}
