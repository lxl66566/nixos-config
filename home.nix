{
  config,
  pkgs,
  catppuccin,
  plasma-manager,
  nix-gaming,
  amber,
  anyrun,
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
    ".local/share/fcitx5/pinyin/customphrase".source = ./config/fcitx5_pinyin_customphrase.txt;
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
    v2raya
    anki
    jellyfin-ffmpeg
    pciutils
    chromium
    uv
    qq
    onlyoffice-bin_latest
    mpv
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
    bitwarden-desktop
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
    impala
    nix-tree
    zed-editor
    wine
    winetricks
    jdk
    easyeffects
    coppwr
    obs-studio
    ida-free
    xonsh
    go
    androidStudioPackages.dev
    nix-index
    # libtas
    (callPackage ./mynixpkgs/libtas.nix { })
    fcitx5-pinyin-zhwiki
    fcitx5-pinyin-moegirl
    fcitx5-pinyin-zhwiki
    shfmt
    tabiew
    mise
    gitui
    onedrivegui
    taplo
    yt-dlp
    podman
    podman-tui
    btdu

    # iperf3
    dnsutils # `dig` + `nslookup`
    # ldns # replacement of `dig`, it provide the command `drill`
    # aria2 # A lightweight multi-protocol & multi-source command-line download utility
    # socat # replacement of openbsd-netcat
    # nmap # A utility for network discovery and security auditing
    # ipcalc # it is a calculator for the IPv4/v6 addresses

    nix-output-monitor
    iftop
    ltrace
    sysstat
    lm_sensors
    ethtool
    pciutils # lspci
    usbutils # lsusb

    osu-lazer-bin
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
        # gc = "git clone --filter=tree:0";
        gcm = "git commit --signoff -am";
        gfixup = "git commit -a --fixup HEAD && GIT_SEQUENCE_EDITOR=: git rebase -i --autosquash HEAD~2";
        py = "python";
        fd = "fd -H";
        nb = "sudo nixos-rebuild switch --show-trace"; # nixos (re)build
        nbf = "nb --fast";
        nd = "nix develop -c $SHELL";
        ndc = "nd && code .";
        rv = "revertversion";
        jc = "journalctl";
        sc = "systemctl";
        remove_color = "sed -i -r 's/\x1b\[[0-9;]*m//g'";
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
    mpv = {
      enable = true;
      config = {
        profile = "fast";
        hwdec = "auto-safe";
        vo = "gpu-next";
        sub-auto = "fuzzy";
      };
      defaultProfiles = [ ];
      bindings = {
        d = "add speed .1";
        a = "add speed -.1";
        s = "set speed 1.0";
        WHEEL_UP = "seek -10";
        WHEEL_DOWN = "seek 10";
        UP = "add volume 2";
        DOWN = "add volume -2";
        z = "seek -7";
        x = "seek 7";
        Z = "seek -2";
        X = "seek 2";
        "Ctrl+w" = "quit";
        "Alt+k" = ''playlist-shuffle ; show-text "$\{playlist}" 4000'';
      };
      # scripts = with pkgs.mpvScripts; [ autoload ];
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
        batdiff
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
        formulahendry.auto-rename-tag
        serayuzgur.crates
        tamasfe.even-better-toml
        jnoortheen.nix-ide
        brettm12345.nixfmt-vscode
        esbenp.prettier-vscode
        ms-python.python
        ms-python.vscode-pylance
        charliermarsh.ruff
        vscodevim.vim
        vue.volar
        llvm-vs-code-extensions.vscode-clangd
        zxh404.vscode-proto3
        rust-lang.rust-analyzer
        # myriad-dreamin.tinymist
        shd101wyy.markdown-preview-enhanced
      ];
    };
    anyrun = {
      enable = true;
      config = {
        plugins = [ ];
        x = {
          fraction = 0.5;
        };
        y = {
          fraction = 0.3;
        };
        width = {
          fraction = 0.3;
        };
        hideIcons = false;
        ignoreExclusiveZones = false;
        layer = "overlay";
        hidePluginInfo = false;
        closeOnClick = true;
        showResultsImmediately = false;
        maxEntries = null;
      };
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
    package = pkgs.aw-server-rust;
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
}
