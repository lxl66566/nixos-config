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
  nix.binaryCaches = [
    "https://mirrors.ustc.edu.cn/nix-channels/store"
    "https://cache.nixos.org/"
  ];
  fonts.fonts = with pkgs; [
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
      ripgrep
      eza
      zoxide
      v2rayA
      unzip
      untar
      p7zip
    ];
  };
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting # Disable greeting
      bind \t forward-word

      function make_new_subvolume -d 'make a btrfs subvol for existing folder'
        set dir $argv
        sudo mv $dir{,.bak}
        sudo btrfs subvolume create $dir
        sudo cp --archive --one-file-system --reflink=always $dir{.bak/*,}
        sudo rm -r --one-file-system $dir'.bak'
      end

      zoxide init fish | source
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
