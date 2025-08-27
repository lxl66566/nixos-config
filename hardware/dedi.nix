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
    device = "/dev/disk/by-uuid/ef46eb00-5095-4f76-a97d-0fa1a9d6a707";
    fsType = "ext4";
  };

  swapDevices = [
    {
      device = "/swapfile";
      size = 500;
    }
  ];

}
