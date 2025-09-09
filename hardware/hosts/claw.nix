{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  boot.kernelModules = [ "kvm-intel" ];
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/7bffb068-8064-4af6-83c8-001b06dc1cb7";
    fsType = "ext4";
  };

  swapDevices = [
    {
      device = "/swapfile";
      size = 1125;
    }
  ];

}
