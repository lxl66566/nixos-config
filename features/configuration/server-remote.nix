{
  lib,
  inputs,
  pkgs,
  features,
  config,
  ...
}:

let
  cert_path_crt = "/var/lib/caddy/certificates/acme-v02.api.letsencrypt.org-directory/${features.server.domain or ""}/${features.server.domain or ""}.crt";
  cert_path_key = "/var/lib/caddy/certificates/acme-v02.api.letsencrypt.org-directory/${features.server.domain or ""}/${features.server.domain or ""}.key";
in

{
  imports = lib.optionals (features.server.domain != null && features.server.as_proxy) [
    ./server-remote-proxy.nix
  ];

  environment = {
    systemPackages = with pkgs; [
      cloud-utils
    ];
    # etc."nixos/config/atuin.key".source = ./config/atuin.key; # cannot source a file with remote build
  };

  swapDevices = lib.mkForce [
    {
      device = "/nix/swapfile";
      size = 512; # 512MB
    }
  ];

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
}
