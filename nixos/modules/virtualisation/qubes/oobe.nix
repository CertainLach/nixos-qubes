{
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkOption
    mkIf
    nameValuePair
    mapAttrs'
    ;
  inherit (lib.types)
    attrsOf
    path
    submodule
    str
    ;

  cfg = config.virtualisation.qubes.dom0.oobe;
in
{
  options.virtualisation.qubes.dom0.oobe = {
    enable = mkEnableOption "Install some templates on boot";

    templates = mkOption {
      type = attrsOf (submodule {
        # TODO: Source type?
        options.source = mkOption {
          description = "Path to template RPM file";
          type = path;
        };
      });
    };
    kernels = mkOption {
      type = attrsOf (submodule {
        # TODO: Source type?
        options = {
          version = mkOption {
            description = "Kernel version portition of the version";
            type = str;
          };
          fedoraVersion = mkOption {
            description = "Kernel fedora version portition of the version";
            type = str;
          };
          kernel = mkOption {
            description = "Path to kernel RPM file";
            type = path;
          };
          modules = mkOption {
            description = "Path to modules RPM file";
            type = path;
          };
        };
      });
    };
  };

  config = mkIf cfg.enable {
    systemd.targets.qubes-oobe-kernels = {
      description = "Target which installs Qubes templates";
      wantedBy = [ "multi-user.target" ];
      after = [ "qubes-oobe-kernels.target" ];
    };
    systemd.targets.qubes-oobe-templates = {
      description = "Target which installs Qubes templates";
      wantedBy = [ "multi-user.target" ];
      after = [ "qubes-oobe-kernels.target" ];
    };
    systemd.services =
      mapAttrs' cfg.templates (
        name: template:
        nameValuePair "qubes-oobe-template-${name}" {
          wantedBy = [ "qubes-oobe-templates.target" ];
          after = [ "qubesd.service" ];

          # TODO: Reinstalling/updating templates?.. It is possible to store template
          # file hash/symlink, compare them with wanted, and then run...
          # But it won't allow removing templates this way. Create a reconciler managing
          # templates marked as installed_by_rpm?
          script = ''
            				if test -d "/var/lib/qubes/vm-templates/${name}"; then
            					echo "template is already installed";
            				fi
            				nixos-qubes-install-template-rpm "${name}" "${template.path}"
            			'';
          path = with pkgs; [ nixos-qubes-tools ];
        }
      )
      // mapAttrs' cfg.kernels (
        name: kernel:
        nameValuePair "qubes-oobe-kernel-${name}" {
          wantedBy = [ "qubes-oobe-kernels.target" ];
          after = [ "qubesd.service" ];

          script = ''
            				if test -d "/var/lib/qubes/vm-kernels/${name}"; then
            					echo "kernel is already installed";
            				fi
            				nixos-qubes-install-kernel-rpm "${name}" \
            					"${kernel.version}" "${kernel.fedoraVersion}" \
            					"${kernel.kernel}" "${kernel.modules}"
            			'';
          path = with pkgs; [ nixos-qubes-tools ];
        }
      );
  };
}
