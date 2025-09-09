{
  lib,
  inputs,
  pkgs,
  features,
  config,
  ...
}:
let
  netconn = pkgs.writeShellApplication {
    name = "netconn";
    text = ''
      if [ "$#" -ne 2 ]; then
        echo "Usage: $0 <ip> <gateway>"
        exit 1
      fi
      set -euxo pipefail
      ip addr flush dev eth0
      ip addr add "$1" dev eth0
      ip link set eth0 up
      ip route add "$2" dev eth0
      ip route add default via "$2"
      echo "nameserver 8.8.8.8" > /etc/resolv.conf
    '';
  };
in
{
  imports = lib.optionals (features.server.domain != null && features.server.as_proxy) [
    ./server-remote-proxy.nix
  ];

  environment = {
    systemPackages = with pkgs; [
      # cloud-utils

      # my package
      netconn
    ];
    # etc."nixos/config/atuin.key".source = ./config/atuin.key; # cannot source a file with remote build
  };

  swapDevices = lib.mkDefault [
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
}

# network reconnect:
# ip addr flush dev eth0
# ip addr add 31.58.223.50/32 dev eth0
# ip link set eth0 up
# ip route add 31.58.223.1 dev eth0
# ip route add default via 31.58.223.1
# nano /etc/resolv.conf
# nameserver 8.8.8.8
