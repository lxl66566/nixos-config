{
  lib,
  pkgs,
  modulesPath,
  features,
  config,
  ...
}:
let
  defaultMountOption = [
    "compress=zstd:11"
    "ssd"
    "noatime"
    "space_cache=v2"
    "discard=async"
  ];
  userHardware = config.userHardware;
in
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  hardware = {
    enableAllFirmware = true;
    cpu.intel.updateMicrocode = true;
    cpu.amd.updateMicrocode = true;
    # nvidia-container-toolkit.enable = false; # 用于 cuda 环境配置与 AI 训练
  };
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  boot = {
    initrd.availableKernelModules = [
      "xhci_pci"
      "ahci"
      "nvme"
      "usbhid"
      "usb_storage"
      "sd_mod"
      "sdhci_pci"
    ];
    initrd.kernelModules = [ ];
    # https://gist.github.com/CMCDragonkai/810f78ee29c8fce916d072875f7e1751
    kernelModules = [
      "kvm-intel"
      "kvm-amd"
      "coretemp"
      "k10temp"
    ];
    extraModulePackages = [ ];
  };

  fileSystems."/" =
    if features.impermanence then
      {
        device = "tmpfs";
        fsType = "tmpfs";
        options = [
          "relatime"
          "mode=755"
        ];
      }
    else
      {
        device = userHardware.main_uuid;
        fsType = "btrfs";
        options = defaultMountOption ++ [ "subvol=root" ];
      };

  fileSystems."/oldroot" = {
    device = userHardware.main_uuid;
    fsType = "btrfs";
    options = defaultMountOption ++ [ "subvol=root" ];
    neededForBoot = true;
  };

  fileSystems."/root" = {
    device = userHardware.main_uuid;
    fsType = "btrfs";
    options = defaultMountOption ++ [ "subvol=userroot" ];
    neededForBoot = true;
  };

  fileSystems."/home" = {
    device = userHardware.main_uuid;
    fsType = "btrfs";
    options = defaultMountOption ++ [ "subvol=home" ];
  };

  fileSystems."/nix" = {
    device = userHardware.main_uuid;
    fsType = "btrfs";
    options = defaultMountOption ++ [ "subvol=nix" ];
  };

  fileSystems."/var" = {
    device = userHardware.main_uuid;
    fsType = "btrfs";
    options = defaultMountOption ++ [ "subvol=var" ];
  };

  fileSystems."/boot" = {
    device = userHardware.boot_uuid;
    fsType = "vfat";
    options = [
      "fmask=0022"
      "dmask=0022"
      "utf8"
      "noatime"
      "errors=remount-ro"
      "iocharset=ascii"
      "shortname=mixed"
    ];
  };
  swapDevices = [ ];
}
