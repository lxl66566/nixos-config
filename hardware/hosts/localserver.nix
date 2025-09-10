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
    ../types.nix
    ../defaultmount.nix
  ];

  config = {
    userHardware = {
      # disk = "/dev/nvme0n1";
      boot_uuid = "/dev/disk/by-uuid/4A07-0E8B";
      main_uuid = "/dev/disk/by-uuid/b39dc135-00a1-4fa7-9b8d-e32740c0031f";
    };
    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  };
}
