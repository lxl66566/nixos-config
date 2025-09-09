{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{

  boot.initrd.availableKernelModules = [
    "virtio_scsi"
    "sr_mod"
  ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/6c40032d-40df-4e0a-90e5-c05b134b88eb";
    fsType = "ext4";
  };

  swapDevices = [
    {
      device = "/swapfile";
      size = 1481;
    }
  ];
}
