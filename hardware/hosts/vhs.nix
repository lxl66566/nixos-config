{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  boot.initrd.availableKernelModules = [
    "ata_piix"
    "uhci_hcd"
    "virtio_pci"
    "virtio_blk"
    "ahci"
    "xen_blkfront"
    "vmw_pvscsi"
  ];
  boot.kernelModules = [ "kvm-intel" ];
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/b8ad7f3d-bf9e-40d4-a533-4656062ae0c2";
    fsType = "ext4";
  };

  swapDevices = [
    {
      device = "/swapfile";
      size = 1076;
    }
  ];

}
