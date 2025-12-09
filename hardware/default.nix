{
  config,
  lib,
  pkgs,
  devicename,
  username,
  features,
  ...
}:
{
  imports = [
    ./hosts
  ]
  ++ (lib.optional (
    features.server.enable && features.server.type == "remote" && features.server.disko
  ) ./disko-vps.nix)
  ++ (lib.optional (features.server.enable && features.server.type == "remote") ./remote-default.nix);

  boot = {
    initrd.systemd.enable = true;
    loader = lib.mkDefault {
      efi.canTouchEfiVariables = true;
      efi.efiSysMountPoint = "/boot";
      grub = {
        enable = !config.boot.isContainer;
        devices = [ "nodev" ];
        efiSupport = true;
        default = "saved";
        useOSProber = false;
      };
      timeout = 15;
      systemd-boot.enable = false;
    };
    kernel.sysctl = {
      "kernel.sysrq" = 1;
      # "kernel.nmi_watchdog" = 0;
      "vm.swappiness" = 130;
      "vm.watermark_boost_factor" = 0;
      "vm.watermark_scale_factor" = 125;
      "vm.page-cluster" = 0;
      "net.core.somaxconn" = 65535;
      "net.core.default_qdisc" = "cake";
      "net.core.netdev_max_backlog" = 16384;
      "net.ipv4.tcp_fastopen" = 3;
      "net.ipv4.tcp_min_snd_mss" = 536;
      "net.ipv4.tcp_congestion_control" = "bbr";
      "net.ipv4.tcp_max_syn_backlog" = 65535;
      "net.ipv4.tcp_tw_reuse" = 1;
      "net.ipv4.ip_local_port_range" = "10240 65535";
      "net.ipv6.conf.all.disable_ipv6" = 1;
      "net.ipv6.conf.default.disable_ipv6" = 1;
      "net.ipv6.conf.lo.disable_ipv6" = 1;
    };
    kernelPackages = pkgs.linuxPackages_zen;
    kernelModules = lib.mkAfter [
      "tcp_bbr"
    ];
    kernelParams = [
      "sysrq_always_enabled=1"
      "amdgpu.sg_display=0"

      # "nvidia_drm.modeset=1"
      # "nvidia_drm.fbdev=1"
      # "acpi_enforce_resources=lax"
      # "i915.modeset=1"
      # "i915.force_probe=46a6"
    ]
    ++ (lib.optionals features.server.enable [
      "audit=0"
      "net.ifnames=0"
    ]);
    supportedFilesystems = [ "ntfs" ];
    tmp = lib.mkDefault {
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
}
