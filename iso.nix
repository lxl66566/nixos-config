# build command:
# BOTH
# nix-shell -p nixos-generators --run "nixos-generate --format iso --configuration ./iso.nix -o result"
# OR
# nix-build '<nixpkgs/nixos>' -A config.system.build.isoImage -I nixos-config=iso.nix --extra-experimental-features flakes

{
  config,
  pkgs,
  lib,
  ...
}:
let
  # 使用 pkgs.writeShellApplication 可以自动处理 shebang 和可执行权限
  create-btrfs = pkgs.writeShellApplication {
    name = "create_btrfs";
    runtimeInputs = [ pkgs.btrfs-progs ]; # 明确脚本依赖
    text = ''
      set -euxo pipefail

      partition="$1"
      if [ -z "$partition" ]; then
        echo "Usage: $0 <partition>"
        exit 1
      fi

      echo "--> Formatting $partition with Btrfs..."
      mkfs.btrfs -f "$partition"

      tmp_mnt=$(mktemp -d)
      # 使用 trap 确保临时目录总能被清理
      trap 'rm -r "$tmp_mnt"' EXIT

      mount "$partition" "$tmp_mnt"

      echo "--> Creating Btrfs subvolumes..."
      for subvol in root home var nix userroot; do
        btrfs subvolume create "$tmp_mnt/$subvol"
      done

      btrfs subvolume list "$tmp_mnt"
      umount "$tmp_mnt"
      echo "--> Done."
    '';
  };

  mount-btrfs = pkgs.writeShellApplication {
    name = "mount_btrfs";
    runtimeInputs = [ pkgs.btrfs-progs ];
    text = ''
      set -euxo pipefail

      partition="$1"
      if [ -z "$partition" ]; then
        echo "Usage: $0 <partition> [boot_partition]"
        exit 1
      fi

      MOUNT_OPTS="compress=zstd:11"

      echo "--> Mounting Btrfs subvolumes from $partition to /mnt..."
      # 确保挂载点存在
      mkdir -p /mnt
      mount -o "$MOUNT_OPTS,subvol=root" "$partition" /mnt

      mkdir -p /mnt/{home,var,nix,root}
      mount -o "$MOUNT_OPTS,subvol=home" "$partition" /mnt/home
      mount -o "$MOUNT_OPTS,subvol=var" "$partition" /mnt/var
      mount -o "$MOUNT_OPTS,subvol=nix" "$partition" /mnt/nix
      mount -o "$MOUNT_OPTS,subvol=userroot" "$partition" /mnt/root

      boot_partition="$2"
      if [ -z "$boot_partition" ]; then
        echo "boot partition not specified, skip mounting boot partition"
      else
        echo "boot partition specified, mounting boot partition"
        mkdir -p /mnt/boot
        mount "$boot_partition" /mnt/boot
      fi

      echo "--> File systems mounted."
    '';
  };

  # 卸载脚本，方便清理
  umount-btrfs = pkgs.writeShellApplication {
    name = "umount_btrfs";
    runtimeInputs = [ pkgs.coreutils ];
    text = ''
      set -e
      echo "--> Unmounting all filesystems under /mnt..."
      # 以相反的顺序卸载，避免 "target is busy" 错误
      umount -R /mnt || echo "Failed to unmount /mnt. It might already be unmounted."
      echo "--> Done."
    '';
  };

  cp-nixos = pkgs.writeShellApplication {
    name = "cp_nixos";
    runtimeInputs = [ pkgs.coreutils ];
    text = ''
      set -e
      echo "--> Copying NixOS configuration..."
      cp -r /iso/nixos /mnt/etc/
      echo "--> Done."
    '';
  };

  filteredSource = builtins.filterSource (
    path: type:
    let
      # 获取路径的基本名称 (例如, "file.txt" 或 "folder")
      baseName = baseNameOf (toString path);
    in
    # 规则: 当文件名不是以下任何一个时，保留该文件 (返回 true)
    baseName != ".git"
    # 排除 .git 目录
    && baseName != "result"
    # 排除 nix-build 的输出结果
    && !lib.hasSuffix ".iso" baseName # 排除所有 .iso 文件
  ) ./.;

in
{
  imports = [
    <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix>

    # Provide an initial copy of the NixOS channel so that the user
    # doesn't need to run "nix-channel --update" first.
    <nixpkgs/nixos/modules/installer/cd-dvd/channel.nix>
    # nix-channel --add https://mirrors.ustc.edu.cn/nix-channels/nixpkgs-unstable nixpkgs
    # nix-channel --add https://mirrors.ustc.edu.cn/nix-channels/nixos-25.05 nixos
  ];

  nixpkgs.config.allowUnfree = true; # needed for enableAllFirmware
  hardware.enableAllFirmware = true;
  console = {
    keyMap = "us";
  };
  networking = lib.mkForce {
    networkmanager.enable = true;
    useDHCP = true;
    firewall.enable = false;
    wireless.iwd = {
      enable = true;
      settings = {
        IPv6 = {
          Enabled = true;
        };
        General = {
          EnableNetworkConfiguration = true;
        };
        Network = {
          EnableIPv6 = true;
          RoutePriorityOffset = 300;
        };
        Settings = {
          AutoConnect = true;
        };
      };
    };
  };
  # boot.kernelParams = [ "copytoram" ]; # no needed
  boot.supportedFilesystems = lib.mkForce [
    "btrfs"
    "reiserfs"
    "vfat"
    "f2fs"
    "xfs"
    "ntfs"
    "cifs"
  ];
  nix.settings = {
    substituters = lib.mkBefore [
      "https://mirrors.ustc.edu.cn/nix-channels/store"
      "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
      "https://mirror.sjtu.edu.cn/nix-channels/store"
      "https://cache.garnix.io"
      "https://mirrors.cernet.edu.cn/nix-channels/store"
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };
  environment = {
    sessionVariables = rec {
      EDITOR = "vim";
      SJTU = "https://mirror.sjtu.edu.cn/nix-channels/store";
      USTC = "https://mirrors.ustc.edu.cn/nix-channels/store";
    };
    systemPackages = with pkgs; [
      sudo
      vim
      ncdu
      lsof
      git
      wget
      curl
      gnutar
      btop
      ripgrep
      fatresize
      yazi
      impala
      efibootmgr
      rsync
      fd
      bat
      ouch
      nixfmt-rfc-style
      xmrig

      # self defined:

      create-btrfs
      mount-btrfs
      umount-btrfs
      cp-nixos
    ];
  };
  users.users =
    let
      conf = {
        shell = pkgs.fish;
        extraGroups = [
          "wheel"
          "networkmanager"
        ];
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA8MA5ciuFugeCNfPwI5yKIuqP4QQvPdWrHZDm9vSgel absx@absx"
        ];
      };
    in
    {
      root = conf;
      nixos = conf;
    };
  programs = {
    fish = {
      enable = true;
      interactiveShellInit = ''
        set fish_greeting # Disable greeting
        set -g fish_trace 1
        bind \t forward-word
      '';
      shellAliases = rec {
        e = "vim";
        l = "ls -alF";
        gp = "git pull";
        gc = "git clone --filter=tree:0";
        gfixup = "git commit -a --fixup HEAD && GIT_SEQUENCE_EDITOR=: git rebase -i --autosquash HEAD~2";
        ni = "sudo nixos-install";
        jc = "journalctl";
        sc = "systemctl";
        nixnix = "sudo nix --extra-experimental-features \"nix-command flakes\"";
        disko-run = "sudo nix --extra-experimental-features \"nix-command flakes\" run github:nix-community/disko/latest -- --mode destroy,format,mount ";
      };
    };
  };

  services = {
    # getty.autologinUser = "root"; # conflict
    dae = {
      enable = true;
      configFile = "/iso/config.dae";
      assets = with pkgs; [
        v2ray-geoip
        v2ray-domain-list-community
      ];
    };
  };
  isoImage.contents = [
    {
      source = ./config/absx.dae;
      target = "/config.dae";
    }
    {
      source = filteredSource;
      target = "/nixos";
    }
    {
      source = ./config/xmrig.json;
      target = "/xmrig.json";
    }
  ];
  isoImage.squashfsCompression = "zstd -Xcompression-level 19";
}
