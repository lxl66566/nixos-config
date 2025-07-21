{
  config,
  pkgs,
  plasma-manager,
  nix-gaming,
  # amber,
  anyrun,
  lib,
  ...
}@inputs:
{
  home.username = "absx";
  home.homeDirectory = "/home/absx";
  home.enableNixpkgsReleaseCheck = false;
  home.stateVersion = "25.05";
  home.file = {
    ".config/cargo/config.toml".source = ./config/cargo.toml;
    ".ssh/config".source = ./config/ssh_config;
    ".config/nixpkgs/config.nix".source = ./config/nix-config.nix;
  };
  home.sessionPath = [ "$HOME/.cargo/bin/" ];
  xsession.numlock.enable = true;

  # 递归将某个文件夹中的文件，链接到 Home 目录下的指定位置
  # home.file.".config/i3/scripts" = {
  #   source = ./scripts;
  #   recursive = true;   # 递归整个文件夹
  #   executable = true;  # 将其中所有文件添加「执行」权限
  # };

  # 直接以 text 的方式，在 nix 配置文件中硬编码文件内容
  # home.file.".xxx".text = ''
  #     xxx
  # '';

  home.packages = with pkgs; [
    trash-cli
    v2raya
    pciutils
    starship
    nix-search-cli
    unrar
    mtr
    dust
    tldr
    cargo-binstall
    nil
    zip
    xz
    unzip
    p7zip
    jq
    yq-go
    difftastic
    feh
    zellij
    delta
    xh
    # lunarvim
    pre-commit
    impala # tui wireless manager
    nix-tree
    nix-index
    # (callPackage ./mynixpkgs/libtas.nix { }) # libtas
    shfmt
    mise
    # gitui
    taplo
    podman
    podman-tui
    btdu
    ouch # compress and decompress painlessly
    efibootmgr # edit efi boot manager
    bfg-repo-cleaner
    cachix
    navi # interactive cli cheatsheet
    bun
    # iperf3
    # ldns # replacement of `dig`, it provide the command `drill`
    # socat # replacement of openbsd-netcat
    # nmap # A utility for network discovery and security auditing

    # trippy # Network diagnostic TUI tool
    iftop
    ltrace
    sysstat
    ethtool
    pciutils # lspci
    usbutils # lsusb
  ]
  # ++ [ inputs.amber.packages.${pkgs.system}.default ]
  ;

  programs = {
    home-manager.enable = true;
    git = {
      enable = true;
      delta.enable = true;
      userName = "lxl66566";
      userEmail = "lxl66566@gmail.com";
    };
    fish = {
      enable = true;
      interactiveShellInit = ''
        set fish_greeting # Disable greeting
        bind \t forward-word
        starship init fish | source
      '';
      shellAliases = rec {
        e = "$EDITOR";
        l = "eza";
        gp = "git pull";
        gc = "git clone --recursive --depth 1";
        gcm = "git commit --signoff -am";
        gfixup = "git commit -a --fixup HEAD && GIT_SEQUENCE_EDITOR=: git rebase -i --autosquash HEAD~2";
        py = "python";
        fd = "fd -H";
        nb = "sudo nixos-rebuild switch"; # nixos (re)build
        nbf = "nb --fast";
        nd = "nix develop -c $SHELL";
        ndb = "git checkout nix -- flake.nix flake.lock && nd && rm flake.nix flake.lock";
        rv = "revertversion";
        jc = "journalctl";
        sc = "systemctl";
        remove_color = "sed -i -r 's/\x1b\[[0-9;]*m//g'";
        tp = "trash-put";
      };
      functions = {
        revertversion = ''
          set cnt (count $argv)

          if test $cnt -ne 1
              echo "Usage: revertversion <_version>"
              return 1
          end

          set _version $argv[1]
          echo "Reverting version $_version"
          git push origin :refs/tags/$_version
          git tag -d $_version
          git tag $_version
          git push --tags
        '';
        merge_video = ''
          find . -name "*.mp4" -exec bash -c 'file="{}"; ffmpeg -i -nostats "$file" -i "$\{file%.mp4}.m4a" -c:v copy -c:a copy -strict experimental "/home/absolutex/Videos/$\{file}"' \;
        '';
        make_new_subvolume = ''
          set dir $argv
          sudo mv $dir{,.bak}
          sudo btrfs subvolume create $dir
          sudo cp --archive --one-file-system --reflink=always $dir{.bak/*,}
          sudo rm -r --one-file-system $dir'.bak'
        '';
      };
    };
    ssh = {
      enable = true;
    };
    atuin = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableZshIntegration = true;
      flags = [ "--disable-ctrl-r" ];
      settings = {
        auto_sync = true;
        dialect = "uk";
        key_path = "/etc/nixos/config/atuin.key";
        show_preview = true;
        style = "compact";
        sync_frequency = "4h";
        sync_address = "https://api.atuin.sh";
        update_check = false;
      };
    };
    bat = {
      enable = true;
      extraPackages = with pkgs.bat-extras; [
        batgrep
        batman
        # batdiff
        batwatch
        prettybat
      ];
      # config = {
      #   style = "plain";
      # };
    };
    eza = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableNushellIntegration = true;
      extraOptions = [
        "--group-directories-first"
        "--header"
        "--all"
        "--long"
        "--binary"
        "--time-style=long-iso"
      ];
      git = true;
      # icons = true;
    };
    zoxide = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      # Replace cd with z and add cdi to access zi
      # options = [ "--cmd cd" ];
    };
    btop = {
      enable = true;
    };
    neovim = {
      enable = true;
      vimAlias = true;
      withNodeJs = true;
      withPython3 = true;
    };
  };

  xdg.configFile = {
    "nvim" = {
      source = pkgs.fetchFromGitHub {
        owner = "AstroNvim";
        repo = "template";
        rev = "20450d8a65a74be39d2c92bc8689b1acccf2cffe";
        sha256 = "sha256-P6AC1L5wWybju3+Pkuca3KB4YwKEdG7GVNvAR8w+X1I=";
      };
      executable = true;
      recursive = true;
    };
  };
}
