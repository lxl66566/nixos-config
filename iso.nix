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
{
  imports = [
    <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix>

    # Provide an initial copy of the NixOS channel so that the user
    # doesn't need to run "nix-channel --update" first.
    <nixpkgs/nixos/modules/installer/cd-dvd/channel.nix>
    # nix-channel --add https://mirrors.ustc.edu.cn/nix-channels/nixpkgs-unstable nixpkgs
    # nix-channel --add https://mirrors.ustc.edu.cn/nix-channels/nixos-25.05 nixos
  ];

  boot.supportedFilesystems = lib.mkForce [
    "btrfs"
    "reiserfs"
    "vfat"
    "f2fs"
    "xfs"
    "ntfs"
    "cifs"
  ];
  nix.settings.substituters = [
    "https://mirrors.ustc.edu.cn/nix-channels/store"
    "https://cache.nixos.org/"
  ];
  environment = {
    sessionVariables = rec {
      EDITOR = "vim";
      SJTU = "https://mirror.sjtu.edu.cn/nix-channels/store";
      USTC = "https://mirrors.ustc.edu.cn/nix-channels/store";
    };
    systemPackages = with pkgs; [
      vim
      ncdu
      lsof
      git
      wget
      curl
      gnutar
      htop
      ripgrep
      fatresize
      yazi
      impala
      efibootmgr
      rsync
      fd
      eza
    ];
  };
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting # Disable greeting
      set -g fish_trace 1

      function create_btrfs
        if test -z "$argv[1]"
          echo "Usage: create_btrfs <partition>"
          return 1
        end

        set partition $argv[1]

        echo "Creating btrfs filesystem on $partition..."
        if not mkfs.btrfs -f "$partition"
          echo "Failed to create btrfs filesystem on $partition."
          return 1
        end
        echo "Btrfs filesystem created successfully."

        set tmp_mnt (mktemp -d)
        if not mount "$partition" "$tmp_mnt"
          echo "Failed to mount the top-level btrfs volume."
          return 1
        end
        echo "Top-level btrfs volume mounted at $tmp_mnt."

        echo "Creating btrfs subvolumes..."
        for subvol in root home var nix userroot
          if not btrfs subvolume create "$tmp_mnt/$subvol"
            echo "Failed to create subvolume $subvol."
            umount "$tmp_mnt"
            rm -r "$tmp_mnt"
            return 1
          end
          echo "Subvolume $subvol created successfully."
        end


        # 4. Unmount the top-level btrfs volume
        if not umount "$tmp_mnt"
          echo "Failed to unmount the top-level btrfs volume."
          rm -r "$tmp_mnt"
          return 1
        end
        rm -r "$tmp_mnt"
        echo "Top-level btrfs volume unmounted."
      end

      function mount_btrfs
        if test -z "$argv[1]"
            echo "Usage: mount_btrfs <partition>"
            return 1
        end
        set partition $argv[1]

        echo "Creating mount points..."
        for mount_point in /mnt /mnt/home /mnt/var /mnt/nix /mnt/userroot
          if not test -d "$mount_point"
            if not mkdir -p "$mount_point"
              echo "Failed to create mount point $mount_point."
              return 1
            end
            echo "Mount point $mount_point created successfully."
          else
            echo "Mount point $mount_point already exists."
          end
        end

        echo "Mounting subvolumes..."
        if not mount -o compress=zstd:11,subvol=root "$partition" /mnt
            echo "Failed to mount root subvolume."
            return 1
        end
        echo "Root subvolume mounted at /mnt."

        if not mount -o compress=zstd:11,subvol=home "$partition" /mnt/home
            echo "Failed to mount home subvolume."
            return 1
        end
        echo "Home subvolume mounted at /mnt/home."

        if not mount -o compress=zstd:11,subvol=var "$partition" /mnt/var
            echo "Failed to mount var subvolume."
            return 1
        end
        echo "Var subvolume mounted at /mnt/var."

        if not mount -o compress=zstd:11,subvol=nix "$partition" /mnt/nix
            echo "Failed to mount nix subvolume."
            return 1
        end
        echo "Nix subvolume mounted at /mnt/nix."

        if not mount -o compress=zstd:11,subvol=userroot "$partition" /mnt/root
            echo "Failed to mount userroot subvolume."
            return 1
        end
        echo "Userroot subvolume mounted at /mnt/root."

        echo "All operations completed successfully!"
        return 0
      end

      bind \t forward-word
    '';
    shellAliases = rec {
      e = "vim";
      l = "eza --all --long --color-scale size --binary --header --time-style=long-iso";
      gp = "git pull";
      gc = "git clone --filter=tree:0";
      gfixup = "git commit -a --fixup HEAD && GIT_SEQUENCE_EDITOR=: git rebase -i --autosquash HEAD~2";
    };
  };
  services = {
    dae = {
      enable = true;
      configFile = "/etc/dae/config.dae";
      assets = with pkgs; [
        v2ray-geoip
        v2ray-domain-list-community
      ];
    };
  };
  isoImage.contents = [
    {
      source = ./config/absx.dae;
      target = "/etc/dae/config.dae";
    }
  ];
  isoImage.squashfsCompression = "zstd";
}
