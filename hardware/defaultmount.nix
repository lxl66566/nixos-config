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
  useDiskoMount =
    !(
      (builtins.hasAttr "boot_uuid" userHardware && userHardware.boot_uuid != null)
      && (builtins.hasAttr "main_uuid" userHardware && userHardware.main_uuid != null)
    ); # 只要不是两个选项都设了，就让 disko 管理挂载
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
    tmp = {
      # https://github.com/NixOS/nixpkgs/blob/nixos-24.05/nixos/modules/system/boot/tmp.nix
      useTmpfs = true;
      tmpfsSize = "80%";
      # useZram = true;
      # zramSettings = {
      #   zram-size = lib.mkDefault "ram * 0.7";
      #   compression-algorithm = "zstd";
      # };
    };
  };

  disko = lib.mkIf (builtins.hasAttr "disk" userHardware && userHardware.disk != null) {
    enableConfig = useDiskoMount;
    devices = {
      disk = {
        main-disk = {
          device = userHardware.disk;
          type = "disk";
          partitioningMode = "gpt";

          partitions = {
            ESP = {
              size = "2G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };

            btrfs = {
              end = "-20G";
              bootable = true;
              content = {
                type = "btrfs";
                subvolumes = {
                  "root" = {
                    mountpoint = if (!features.impermanence) then "/" else "/oldroot";
                    mountOptions = defaultMountOption;
                  };
                  "home" = {
                    mountpoint = "/home";
                    mountOptions = defaultMountOption;
                  };
                  "var" = {
                    mountpoint = "/var";
                    mountOptions = defaultMountOption;
                  };
                  "nix" = {
                    mountpoint = "/nix";
                    mountOptions = defaultMountOption;
                  };
                  "userroot" = {
                    mountpoint = "/root";
                    mountOptions = defaultMountOption;
                  };
                };
              };
            };
          };
        };
      };
    };
  };

  fileSystems."/" = lib.mkIf features.impermanence {
    device = "tmpfs";
    fsType = "tmpfs";
    options = [
      "relatime"
      "mode=755"
    ];
  };

  fileSystems."/oldroot" = lib.mkIf (!useDiskoMount) {
    device = userHardware.main_uuid;
    fsType = "btrfs";
    options = defaultMountOption ++ [ "subvol=root" ];
    neededForBoot = true;
  };

  fileSystems."/root" = lib.mkIf (!useDiskoMount) {
    device = userHardware.main_uuid;
    fsType = "btrfs";
    options = defaultMountOption ++ [ "subvol=userroot" ];
    neededForBoot = true;
  };

  fileSystems."/home" = lib.mkIf (!useDiskoMount) {
    device = userHardware.main_uuid;
    fsType = "btrfs";
    options = defaultMountOption ++ [ "subvol=home" ];
  };

  fileSystems."/nix" = lib.mkIf (!useDiskoMount) {
    device = userHardware.main_uuid;
    fsType = "btrfs";
    options = defaultMountOption ++ [ "subvol=nix" ];
  };

  fileSystems."/var" = lib.mkIf (!useDiskoMount) {
    device = userHardware.main_uuid;
    fsType = "btrfs";
    options = defaultMountOption ++ [ "subvol=var" ];
  };

  fileSystems."/boot" = lib.mkIf (!useDiskoMount) {
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
