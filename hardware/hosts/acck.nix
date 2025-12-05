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
    device = "/dev/disk/by-uuid/8d4348f6-6443-481d-bf2e-48af79d00715";
    fsType = "ext4";
  };

  swapDevices = [
    {
      device = "/swapfile";
      size = 500;
    }
  ];

}
