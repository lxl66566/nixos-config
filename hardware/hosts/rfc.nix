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
    device = "/dev/disk/by-uuid/244e2acb-8804-4805-99ab-a88a8812170f";
    fsType = "ext4";
  };

  swapDevices = [
    {
      device = "/swapfile";
      size = 1481;
    }
  ];
}
