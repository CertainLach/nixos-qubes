{
  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/master";
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
          composeExtensions (import ./pkgs/top-level/overlay.nix) (
            import "${inputs.nixpkgs}/pkgs/top-level/by-name-overlay.nix" ./pkgs/by-name
          );
        flake.overlays.default = self.flake.overlays.qubesPackages;

        flake.nixosModules.qubesDom0 = {
          config.nixpkgs.overlays = [ self.flake.overlays.default ];
          _file = ./flake.nix;
        };

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
                qubes-seabios
                qubes-vmm-stubdom-linux
                ;
              inherit (pkgs.python3.pkgs)
                qubes-vmm-xen
                ;

              # Those packages are both python3Package and normal package, choosen one is above.
              # inherit (pkgs) qubes-vmm-xen;
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
