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
    ./defaultmount.nix
  ];

  options.userHardware = {
    boot_uuid = lib.mkOption {
      type = lib.types.str;
    };
    main_uuid = lib.mkOption {
      type = lib.types.str;
    };
  };

  config = {
    userHardware = {
      boot_uuid = "/dev/disk/by-uuid/209D-7E96";
      main_uuid = "/dev/disk/by-uuid/3f9c46c9-efa8-4f9e-9dcf-77226f28b75b";
    };

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    hardware.graphics = {
      enable = true;
      extraPackages = with pkgs; [
        vpl-gpu-rt # for intel Arc A750 GPU
        # intel-media-driver # LIBVA_DRIVER_NAME=iHD
        # intel-ocl
        # intel-vaapi-driver # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
        # intel-compute-runtime
        # vaapiVdpau
        # libvdpau-va-gl
        # mesa
        # nvidia-vaapi-driver
        # nv-codec-headers-12
      ];
      # extraPackages32 = with pkgs.pkgsi686Linux; [
      #   intel-media-driver
      #   intel-vaapi-driver
      #   vaapiVdpau
      #   mesa
      #   libvdpau-va-gl
      # ];
    };
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
