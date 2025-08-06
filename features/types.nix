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
      description = "Enable gaming features and steam.";
    };
    desktop = lib.mkOption {
      type = lib.types.bool;
      description = "for graphics displaying system.";
    };
    laptop = lib.mkOption {
      type = lib.types.bool;
      description = "for laptop, which needs performance control and power management.";
    };
    programming = lib.mkOption {
      type = lib.types.bool;
      description = "Enable programming tools, packages.";
    };
    mining = lib.mkOption {
      type = lib.types.bool;
      description = "Enable xmrig and relative settings.";
    };
    mini = lib.mkOption {
      type = lib.types.bool;
      description = "Enable device that has very little resources, often used for bootstrapping.";
    };
    wsl = lib.mkOption {
      type = lib.types.bool;
      description = "Enable features for nixos that on windows subsystem of linux.";
    };
    like_to_build = lib.mkOption {
      type = lib.types.bool;
      description = "Some packages are not so widely used, so the nix cache often misses and needs to build them.";
    };
    impermanence = lib.mkOption {
      type = lib.types.bool;
      description = "For bootstraping to root_on_tmpfs. If set to true, you are aware of the impermanence usage and risks.";
    };
    server = lib.mkOption {
      type = lib.types.submodule {
        options = {
          enable = lib.mkOption {
            type = lib.types.bool;
            description = "Enable ssh";
          };
          type = lib.mkOption {
            type = lib.types.enum [
              "local"
              "remote"
            ];
            description = "Server type.";
          };
          domain = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            description = "Domain of the remote server.";
          };
          as_proxy = lib.mkOption {
            type = lib.types.bool;
            description = "Use this server as a proxy node.";
          };
          disk_name = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            description = "The disk name of the remote server.";
          };
          network = lib.mkOption {
            type = config.systemd.network.type;
            description = "The systemd network options of the remote server.";
          };
        };
      };
      description = "for remote connection (openssh) and other setups like disko";
    };
  };
  config.features = features;
}
