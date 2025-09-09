# the type definition of my features
{
  lib,
  config,
  features,
  ...
}:
{
  options.features = {
    gaming = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable gaming features and steam.";
    };
    desktop = lib.mkOption {
      type = lib.types.listOf (
        lib.types.enum [
          "plasma"
          "niri"
        ]
      );
      default = [ ];
      description = "graphics displaying systems to use.";
    };
    laptop = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "for laptop, which needs performance control and power management.";
    };
    programming = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable programming tools, packages.";
    };
    mining = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable xmrig and relative settings.";
    };
    mini = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable device that has very little resources, often used for bootstrapping.";
    };
    wsl = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable features for nixos that on windows subsystem of linux.";
    };
    like_to_build = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Some packages are not so widely used, so the nix cache often misses and needs to build them.";
    };
    impermanence = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "For bootstraping to root_on_tmpfs. If set to true, you are aware of the impermanence usage and risks.";
    };
    server = lib.mkOption {
      type = lib.types.submodule {
        options = {
          enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable ssh";
          };
          type = lib.mkOption {
            type = lib.types.enum [
              "local"
              "remote"
            ];
            default = "local";
            description = "Server type.";
          };
          domain = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = "Domain of the remote server.";
          };
          as_proxy = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Use this server as a proxy node.";
          };
          disk_name = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = "/dev/vda";
            description = "The disk name of the remote server.";
          };
          disko = lib.mkOption {
            type = lib.types.nullOr lib.types.bool;
            default = null;
            description = "whether to use disko to generate image and dd to vps.";
          };
          networking = lib.mkOption {
            type = lib.types.nullOr config.networking.type;
            default = null;
            description = "The nixos network options of the remote server, will be merged with the default networking config.";
          };
        };
      };
      description = "for remote connection (openssh) and other setups like proxy, disko, etc.";
    };
    others = lib.mkOption {
      type = lib.types.listOf lib.types.path;
      default = [ ];
      description = "extra configurations' paths";
    };
  };

  config.features = features;
  config.assertions = lib.optional (config.disko == true) {
    assertion = config.disk_name != null;
    message = "When disko is enabled, disk_name must be set.";
  };
}
