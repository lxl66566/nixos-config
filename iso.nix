# build command:
# nix-build '<nixpkgs/nixos>' -A config.system.build.isoImage -I nixos-config=iso.nix --extra-experimental-features flakes

{ config, pkgs, ... }:
{
  imports = [
    <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix>

    # Provide an initial copy of the NixOS channel so that the user
    # doesn't need to run "nix-channel --update" first.
    <nixpkgs/nixos/modules/installer/cd-dvd/channel.nix>
    # nix-channel --add https://mirrors.ustc.edu.cn/nix-channels/nixpkgs-unstable nixpkg
    # nix-channel --add https://mirrors.ustc.edu.cn/nix-channels/nixos-24.05 nixos
  ];
  nix.settings.substituters = [
    "https://mirrors.ustc.edu.cn/nix-channels/store"
    "https://cache.nixos.org/"
  ];
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk
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
      dust
      lsof
      git
      wget
      curl
      htop
      dae
      ripgrep
      fatresize
      yazi
      impala
    ];
  };
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting # Disable greeting
      set -g fish_trace 1

      function mymount -d 'mount my partitions'
        echo "input the btrfs partition position (ex. /dev/nvme1n1p4):"
        set partition (readline)
        if test -z "$partition"
          echo "please input one."
          exit 1
        end
        mount -o compress=zstd:11,subvol=root "$partition" /mnt || exit 1
        mount -o compress=zstd:11,subvol=home "$partition" /mnt/home || exit 1
        mount -o compress=zstd:11,subvol=var "$partition" /mnt/var || exit 1
        mount -o compress=zstd:11,subvol=nix "$partition" /mnt/nix || exit 1

        echo "input the boot partition position (ex. /dev/nvme1n1p1):"
        set partition (readline)
        mount "$partition" /mnt/boot || exit 1
      end


      function mymount2 -d 'mount my partitions, powered by gpt' -a partition boot_partition
        # 如果未提供参数，依然可以通过 readline 获取
        if not set partition; and not set boot_partition
          echo "Please provide partition positions as arguments or interactively."
          return 1
        end
        # 验证分区路径
        if not test -b "$partition" -o not test -b "$boot_partition"
          echo "One or both provided partitions are not valid block devices."
          return 1
        end
        # 挂载 Btrfs 子卷
        for subvol in root home var nix
          mount -o compress=zstd:11,subvol="$subvol" "$partition" /mnt/"$subvol" || { echo "Failed to mount subvol $subvol"; return 1; }
        end
        # 挂载 boot 分区
        mount "$boot_partition" /mnt/boot || { echo "Failed to mount boot partition"; return 1; }
        echo "All partitions mounted successfully."
      end

      bind \t forward-word
    '';
    shellAliases = rec {
      e = "vim";
      l = "eza --all --long --color-scale size --binary --header --time-style=long-iso";
      gp = "git pull";
      gc = "git clone --filter=tree:0";
      gfixup = "git commit -a --fixup HEAD && GIT_SEQUENCE_EDITOR=: git rebase -i --autosquash HEAD~2";
      ni = ''nixos-install --option substituters "https://mirror.sjtu.edu.cn/nix-channels/store"'';
    };
  };
}
