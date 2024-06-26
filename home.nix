{
  config,
  pkgs,
  catppuccin,
  ...
}:
{
  imports = [
    ./others/eye-protection.nix
    catppuccin.homeManagerModules.catppuccin
  ];

  home.username = "absx";
  home.homeDirectory = "/home/absx";
  home.enableNixpkgsReleaseCheck = false;
  home.stateVersion = "24.05";
  home.file = {
    ".config/cargo/config.toml".source = ./config/cargo.toml;
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
    tree
    wget
    floorp
    vscode
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
    bottles
    qq
    onlyoffice-bin_latest
    mpv
    activitywatch
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

    # iperf3
    dnsutils # `dig` + `nslookup`
    # ldns # replacement of `dig`, it provide the command `drill`
    # aria2 # A lightweight multi-protocol & multi-source command-line download utility
    # socat # replacement of openbsd-netcat
    # nmap # A utility for network discovery and security auditing
    # ipcalc # it is a calculator for the IPv4/v6 addresses

    # file
    # which
    # tree
    # gnused
    # gawk

    # # nix related
    # #
    # # it provides the command `nom` works just like `nix`
    # # with more details log output
    # nix-output-monitor

    # iftop # network monitoring

    # # system call monitoring
    # ltrace # library call monitoring

    # # system tools
    sysstat
    # lm_sensors # for `sensors` command
    ethtool
    pciutils # lspci
    usbutils # lsusb
  ];

  # alacritty - 一个跨平台终端，带 GPU 加速功能
  # programs.alacritty = {
  #   enable = true;
  #   # 自定义配置
  #   settings = {
  #     env.TERM = "xterm-256color";
  #     font = {
  #       size = 12;
  #       draw_bold_text_with_bright_colors = true;
  #     };
  #     scrolling.multiplier = 5;
  #     selection.save_to_clipboard = true;
  #   };
  # };

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

        function make_new_subvolume -d 'make a btrfs subvol for existing folder'
          set dir $argv
          sudo mv $dir{,.bak}
          sudo btrfs subvolume create $dir
          sudo cp --archive --one-file-system --reflink=always $dir{.bak/*,}
          sudo rm -r --one-file-system $dir'.bak'
        end

        function merge_video --description 'merge video and audio that downloaded by yt-dlp'
          find . -name "*.mp4" -exec bash -c 'file="{}"; ffmpeg -i -nostats "$file" -i "$\{file%.mp4}.m4a" -c:v copy -c:a copy -strict experimental "/home/absolutex/Videos/$\{file}"' \;
        end

        function revertversion
          set cnt (count $argv)

          if test $cnt -ne 1
              echo "Usage: revertversion <version>"
              return 1
          end

          set version $argv[1]
          echo "Reverting version $version"
          git push origin :refs/tags/$version
          git tag -d $version
          git tag $version
          git push --tags
        end

        starship init fish | source
      '';
      shellAliases = rec {
        e = "vim";
        l = "eza";
        gp = "git pull";
        # gc = "git clone --filter=tree:0";
        gfixup = "git commit -a --fixup HEAD && GIT_SEQUENCE_EDITOR=: git rebase -i --autosquash HEAD~2";
        py = "python";
        fd = "fd -H";
        nb = "sudo nixos-rebuild switch --show-trace"; # nixos (re)build
        rv = "revertversion";
        jc = "journalctl";
        sc = "systemctl";
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
      defaultProfiles = [ "save-position-on-quit" ];
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
      options = [ "--cmd cd" ];
    };
    btop = {
      enable = true;
    };
  };

  # region wallpaper
  #
  # Run this command above:
  # cd ~/Pictures && git clone git@github.com:lxl66566/wallpaper.git
  # services.random-background = {
  #   enable = true;
  #   imageDirectory = "%h/Pictures/wallpaper";
  #   interval = "6h";
  # };
}
