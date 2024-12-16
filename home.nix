{
  config,
  pkgs,
  catppuccin,
  plasma-manager,
  nix-gaming,
  amber,
  anyrun,
  lib,
  ...
}@inputs:
{
  imports = [
    ./others/eye-protection.nix
    plasma-manager.homeManagerModules.plasma-manager
    ./others/plasma.nix
    catppuccin.homeManagerModules.catppuccin
  ];

  home.username = "absx";
  home.homeDirectory = "/home/absx";
  home.enableNixpkgsReleaseCheck = false;
  home.stateVersion = "24.05";
  home.file = {
    ".config/cargo/config.toml".source = ./config/cargo.toml;
    ".ssh/config".source = ./config/ssh_config.txt;
    # ".local/share/fcitx5/pinyin/customphrase".text =
    #   builtins.readFile (./config/fcitx5_pinyin_secrets.txt)
    #   + "\n"
    #   + builtins.readFile (./config/fcitx5_pinyin_customphrase.txt);
    ".config/mpv".source = ./config/mpv;
    ".config/niri/config.kdl".source = ./config/niri.kdl;
    ".config/nixpkgs/config.nix".source = ./config/nix-config.nix;
    "auto-cpufreq/auto-cpufreq.conf".source = ./config/auto-cpufreq.conf;
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
    vim
    gcc
    gnumake
    cmake
    tree
    wget
    floorp
    telegram-desktop
    fastfetch
    nodejs_22
    corepack_22
    kdePackages.yakuake
    rustup
    # v2raya
    anki
    jellyfin-ffmpeg
    pciutils
    chromium
    uv
    qq
    onlyoffice-bin_latest
    starship
    devenv
    xclip
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
    gnutar
    jq
    yq-go
    nvtopPackages.nvidia
    android-tools
    sccache
    difftastic
    # bitwarden-desktop
    qpwgraph
    feh
    losslesscut-bin
    zellij
    llvmPackages_18.clang-tools
    qbittorrent
    delta
    xh
    feishu
    lunarvim
    pre-commit
    impala # tui wireless manager
    nix-tree
    zed-editor
    wine
    winetricks
    jdk
    easyeffects
    coppwr
    obs-studio
    # ida-free
    xonsh
    go
    androidStudioPackages.dev
    gradle
    nix-index
    # (callPackage ./mynixpkgs/libtas.nix { }) # libtas
    fcitx5-pinyin-zhwiki
    fcitx5-pinyin-moegirl
    fcitx5-pinyin-zhwiki
    shfmt
    tabiew # tw: Tabiew is a lightweight, terminal-based application to view and query delimiter separated value formatted documents, such as CSV and TSV files
    mise
    gitui
    # onedrivegui
    taplo
    mpv
    yt-dlp
    typst
    podman
    podman-tui
    btdu
    lm_sensors
    pkg-config
    gh
    # arc-browser # not supported on x86_64 unknown linux
    # brave
    zig # programming language
    leiningen # clojure package manager
    clojure # functional language
    # discord # chat platform
    ouch # compress and decompress painlessly
    # jd-gui # java decompiler 
    # jd-gui has been removed due to a dependency on the dead JCenter Bintray. Other Java decompilers in Nixpkgs include bytecode-viewer (GUI), cfr (CLI), and procyon (CLI).
    efibootmgr # edit efi boot manager
    pipx # python binary package manager
    octave # scientific computing
    gimp # image editor
    mtpaint # a simple whiteboard
    # vivaldi # track https://github.com/NixOS/nixpkgs/issues/309056
    fsearch
    microsoft-edge
    xorg.libxcb.dev
    bfg-repo-cleaner
    xcolor
    cachix
    navi
    cljfmt
    wechat-uos
    # biome
    # deno
    bun
    libreoffice-qt6-still
    localsend
    hyperfine # A command-line benchmarking tool

    # iperf3
    dnsutils # `dig` + `nslookup`
    # ldns # replacement of `dig`, it provide the command `drill`
    aria2 # A lightweight multi-protocol & multi-source command-line download utility
    # socat # replacement of openbsd-netcat
    # nmap # A utility for network discovery and security auditing

    trippy
    iftop
    ltrace
    sysstat
    lm_sensors
    ethtool
    pciutils # lspci
    usbutils # lsusb
    cargo-msrv

    osu-lazer-bin

    # testdev
    # jmeter
    # postman

    # flatpak
    flatpak
    flatpak-builder
  ]
  # ++ (with nix-gaming.packages.${pkgs.system}; [ osu-stable ])
  # ++ [ inputs.amber.packages.${pkgs.system}.default ]
  # ++ [ anyrun.packages.${system}.anyrun ]
  ;

  catppuccin = {
    enable = true;
    flavor = "mocha";
  };
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
    poetry = {
      enable = true;
      settings = {
        virtualenvs.create = true;
        virtualenvs.in-project = true;
      };
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
      catppuccin.enable = true;
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
    vscode = {
      enable = true;
      # package = pkgs.vscode.fhs;
      extensions = with pkgs.vscode-extensions; [
        jnoortheen.nix-ide
        brettm12345.nixfmt-vscode
        charliermarsh.ruff
        vscodevim.vim
        rust-lang.rust-analyzer
      ];
    };
    neovim = {
      enable = true;
      vimAlias = true;
      withNodeJs = true;
      withPython3 = true;
    };
    alacritty = {
      enable = true;
    };
    fuzzel = {
      enable = true;
    };
  };

  # Run this command above:
  # cd ~/Pictures && git clone git@github.com:lxl66566/wallpaper.git
  # services.random-background = {
  #   enable = true;
  #   imageDirectory = "%h/Pictures/wallpaper";
  #   interval = "6h";
  # };
  services.activitywatch = {
    enable = true;
    # package = pkgs.aw-server-rust;
    package = pkgs.activitywatch;
    watchers = {
      aw-watcher-afk = {
        package = pkgs.activitywatch;
        settings = {
          timeout = 300;
          poll_time = 2;
        };
      };
      aw-watcher-windows = {
        package = pkgs.activitywatch;
        settings = {
          poll_time = 1;
          exclude_title = true;
        };
      };
    };
    settings = {
      timeout = 180;
    };
  };
  services.mako = {
    enable = true;
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
