{
  config,
  lib,
  pkgs,
  modulesPath,
  features,
  ...
}:
{
  imports = [
    ../types.nix
    ../defaultmount.nix
  ]
  ++ (lib.optionals (features.desktop != [ ] && !features.wsl && features.like_to_build) [
    ../specific/amdgpu.nix
  ]);

  config = {
    userHardware = {
      boot_uuid = "/dev/disk/by-uuid/209D-7E96";
      main_uuid = "/dev/disk/by-uuid/3f9c46c9-efa8-4f9e-9dcf-77226f28b75b";
    };

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    hardware.graphics = {
      enable = lib.mkDefault true;
      enable32Bit = lib.mkDefault true;
    };
    boot.loader.grub.default = lib.mkForce 1;
    boot.loader.grub.extraEntries = ''
      menuentry "Windows 11 (zh)" {
        search --fs-uuid D247-DFCF --set=root
        chainloader /EFI/Microsoft/Boot/bootmgfw.efi
      }
      menuentry "Windows 10 LTSC (jp)" {
        search --fs-uuid 209D-7E96 --set=root
        chainloader /EFI/Microsoft/Boot/bootmgfw.efi
      }
    '';

    #hardware.nvidia = {
    #  modesetting.enable = true;
    #  prime = {
    #    intelBusId = "PCI:0:2:0";
    #    nvidiaBusId = "PCI:1:0:0";
    #    sync.enable = true;
    #  };
    #  powerManagement.enable = false;
    #  powerManagement.finegrained = false;
    #  open = true;
    #  nvidiaSettings = true;
    #  package = config.boot.kernelPackages.nvidiaPackages.stable;
    #};
  };
}
