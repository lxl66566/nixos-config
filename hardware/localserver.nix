{
  lib,
  pkgs,
  modulesPath,
  features,
  config,
  ...
}:
{
  imports = [
    ./defaultmount.nix
  ];

  options.userHardware = {
    boot_uuid = lib.mkOption {
      type = lib.types.str;
    };
    main_uuid = lib.mkOption {
      type = lib.types.str;
    };
  };

  config = {
    userHardware = {
      boot_uuid = "/dev/disk/by-uuid/114E-D812";
      main_uuid = "/dev/disk/by-uuid/713b8682-b459-49eb-9676-c02c61eff50e";
    };
    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  };
}
