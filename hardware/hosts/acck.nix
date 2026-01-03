{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  boot.initrd.availableKernelModules = [
    "sd_mod"
    "sr_mod"
  ];
  boot.kernelModules = [ "kvm-intel" ];
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/cd27991d-2202-4b08-85cc-a8c446ea5234";
    fsType = "ext4";
  };

  swapDevices = [
    {
      device = "/swapfile";
      size = 500;
    }
  ];

}
