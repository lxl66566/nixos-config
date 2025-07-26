{
  lib,
  inputs,
  pkgs,
  features,
  config,
  ...
}:

lib.mkIf (features.server.enable && features.server.type == "remote") {
  boot.initrd = {
    compressor = "zstd";
    compressorArgs = [
      "-19"
      "-T0"
    ];
    postDeviceCommands = lib.mkIf (!config.boot.initrd.systemd.enable) ''
      # Set the system time from the hardware clock to work around a
      # bug in qemu-kvm > 1.5.2 (where the VM clock is initialised
      # to the *boot time* of the host).
      hwclock -s
    '';
    availableKernelModules = [
      "virtio_net"
      "virtio_pci"
      "virtio_mmio"
      "virtio_blk"
      "virtio_scsi"
    ];
    kernelModules = [
      "virtio_balloon"
      "virtio_console"
      "virtio_rng"
    ];
  };
  boot.loader.grub.devices = [ "/dev/vda" ];

  services = {
    caddy = {
      enable = features.server.domain != null && features.server.as_proxy && !features.mini;
      configFile = pkgs.writeText "Caddyfile" ''
        {
          ${features.server.domain}

          reverse_proxy https://caddyserver.com/
        }
      '';
    };
  };
}
