{
  self,
  pkgs,
  lib,
  features,
  username,
  inputs,
  useBtrfs,
  ...
}:
{
  imports = [
    inputs.stylix.nixosModules.stylix
    # ${self}/others/vm.nix
    "${self}/others/neovim.nix"
  ];
  hardware = {
    bluetooth = {
      enable = true; # enables support for Bluetooth
      powerOnBoot = false; # powers up the default Bluetooth controller on boot
    };
    graphics = {
      enable = true;
      enable32Bit = true;
    };
  };

  # region fonts and ime
  fonts = {
    fontDir.enable = true;
    enableDefaultPackages = true;
    packages = with pkgs; [
      noto-fonts
      # 'noto-fonts-cjk' has been renamed to/replaced by 'noto-fonts-cjk-sans'
      noto-fonts-cjk-serif
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      liberation_ttf
      fira-code
      fira-code-symbols
      source-code-pro
      source-han-sans
      source-han-serif
      sarasa-gothic
      ipafont
      vista-fonts-chs
    ];
    fontconfig = {
      defaultFonts = {
        emoji = [ "Noto Color Emoji" ];
        monospace = [
          "DejaVu Sans Mono"
          "Fira Code"
          "Noto Sans Mono CJK SC"
          "Sarasa Mono SC"
        ];
        sansSerif = [
          "DejaVu Sans"
          "Fira Code Sans"
          "Noto Sans CJK SC"
          "Source Han Sans SC"
        ];
        serif = [
          "DejaVu Serif"
          "Fira Code Serif"
          "Noto Serif CJK SC"
          "Source Han Serif SC"
        ];
      };
      cache32Bit = true;
      antialias = true; # 抗锯齿
    };
  };
  i18n = rec {
    defaultLocale = "zh_CN.UTF-8";
    supportedLocales = lib.mkBefore [
      "C.UTF-8/UTF-8"
      "en_US.UTF-8/UTF-8"
      "en_SG.UTF-8/UTF-8"
      "ja_JP.UTF-8/UTF-8"
      "zh_CN.UTF-8/UTF-8"
    ];
    extraLocaleSettings = {
      # LANG = defaultLocale;
      # LC_ALL = defaultLocale;
    };
    inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5.addons = with pkgs; [
        fcitx5-rime
        # fcitx5-chinese-addons
        # fcitx5-mozc
        # fcitx5-gtk
        # fcitx5-configtool
      ];
      # type = "ibus";
      # ibus.engines = with pkgs.ibus-engines; [
      #   rime
      #   libpinyin
      # ];
    };
  };

  services = {
    xserver = {
      enable = true;
      videoDrivers = lib.mkBefore [
        "modesetting"
        "fbdev"
        "amdgpu"
        # "nvidia"
      ];
    };
    displayManager = {
      sddm = {
        enable = true;
        autoNumlock = true;
      };
      defaultSession = "plasmax11";
      autoLogin = {
        enable = false;
        user = username;
      };
    };
    safeeyes.enable = false;

    libinput.enable = true;
    pipewire = {
      enable = true;
      pulse.enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      jack.enable = true;
      lowLatency = {
        enable = true;
        quantum = 64;
        rate = 48000;
      };
      extraConfig = {
        pipewire."92-low-latency" = {
          context.properties = {
            default.clock.rate = 48000;
            default.clock.quantum = 32;
            default.clock.min-quantum = 32;
            default.clock.max-quantum = 32;
          };
        };
        pipewire-pulse."92-low-latency" = {
          context.modules = [
            {
              name = "libpipewire-module-protocol-pulse";
              args = {
                pulse.min.req = "32/48000";
                pulse.default.req = "32/48000";
                pulse.max.req = "32/48000";
                pulse.min.quantum = "32/48000";
                pulse.max.quantum = "32/48000";
              };
            }
          ];
          stream.properties = {
            node.latency = "32/48000";
            resample.quality = 1;
          };
        };
      };
      wireplumber.configPackages = [
        (pkgs.writeTextDir "share/wireplumber/main.lua.d/99-alsa-lowlatency.lua" ''
          alsa_monitor.rules = {
            {
              matches = {{{ "node.name", "matches", "alsa_output.*" }}};
              apply_properties = {
                ["audio.format"] = "S32LE",
                ["audio.rate"] = "96000", -- for USB soundcards it should be twice your desired rate
                ["api.alsa.period-size"] = 2, -- defaults to 1024, tweak by trial-and-error
                -- ["api.alsa.disable-batch"] = true, -- generally, USB soundcards use the batch mode
              },
            },
          }
        '')
      ];
    };
  };

  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

  programs = {
    nix-ld = {
      enable = true;
      libraries =
        with pkgs;
        # (steam-run.fhsenv.args.multiPkgs pkgs)
        # ++
        [
          alsa-lib
          at-spi2-atk
          at-spi2-core
          atk
          cairo
          cups
          curl
          dbus
          expat
          fontconfig
          freetype
          fuse3
          gdk-pixbuf
          glib
          gtk3
          icu
          libGL
          libappindicator-gtk3
          libdrm
          libglvnd
          libnotify
          libpulseaudio
          libunwind
          libusb1
          libuuid
          libxkbcommon
          libxml2
          mesa
          nspr
          nss
          openssl
          pango
          pipewire
          stdenv.cc.cc
          systemd
          vulkan-loader
          xorg.libX11
          xorg.libXScrnSaver
          xorg.libXcomposite
          xorg.libXcursor
          xorg.libXdamage
          xorg.libXext
          xorg.libXfixes
          xorg.libXi
          xorg.libXrandr
          xorg.libXrender
          xorg.libXtst
          xorg.libxcb
          xorg.libxkbfile
          xorg.libxshmfence
          zlib
        ];
    };
  };

  stylix = {
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
    polarity = "dark";
    targets.gnome-text-editor.enable = false;
  };

  # region home-manager
  home-manager.users.${username} = {
    imports = [
      inputs.stylix.homeModules.stylix
    ];

    home.file = {
      ".config/mpv".source = "${self}/config/mpv";
    };

    home.packages =
      with pkgs;
      [
        trash-cli
        ayugram-desktop
        anki
        jellyfin-ffmpeg
        losslesscut-bin # lossless video/audio editing
        qq
        wechat-uos
        onlyoffice-desktopeditors
        # flameshot # many bugs!
        fsearch # fast file search like everything
        # libreoffice-qt6-still
        xclip
        # nvtopPackages.nvidia
        # qpwgraph
        # qbittorrent
        easyeffects
        # coppwr  # Low level control GUI for the PipeWire multimedia server
        obs-studio
        # xonsh
        tabiew # tw: Tabiew is a lightweight, terminal-based application to view and query delimiter separated value formatted documents, such as CSV and TSV files
        mpv
        yt-dlp

        microsoft-edge
        firefox
        chromium
        # floorp
        # arc-browser # not supported on x86_64 unknown linux
        # brave
        # vivaldi # track https://github.com/NixOS/nixpkgs/issues/309056

        # discord # chat platform
        gimp # image editor
        # mtpaint # a simple whiteboard
        xorg.libxcb.dev
        xcolor
        localsend
        hyperfine # A command-line benchmarking tool
        # aria2
        # flatpak
        # flatpak-builder
      ]
      ++ (lib.optionals (useBtrfs) [
        btdu
      ])
      ++ (lib.optionals (!features.mini && !(features.server.enable && features.server.type == "remote"))
        [

          # https://nixos-and-flakes.thiscute.world/zh/best-practices/run-downloaded-binaries-on-nixos
          (
            let
              base = pkgs.appimageTools.defaultFhsEnvArgs;
            in
            pkgs.buildFHSEnv (
              base
              // {
                name = "fhs";
                targetPkgs =
                  pkgs:
                  (
                    # pkgs.buildFHSEnv 只提供一个最小的 FHS 环境，缺少很多常用软件所必须的基础包
                    # 所以直接使用它很可能会报错
                    #
                    # pkgs.appimageTools 提供了大多数程序常用的基础包，所以我们可以直接用它来补充
                    (base.targetPkgs pkgs)
                    ++ (with pkgs; [
                      pkg-config
                      ncurses
                      # 如果你的 FHS 程序还有其他依赖，把它们添加在这里
                    ])
                  );
                profile = "export FHS=1";
                runScript = "fish";
                extraOutputsToInstall = [ "dev" ];
              }
            )
          )
        ]
      );
    programs = {
      vscode = {
        enable = true;
        # package = pkgs.vscode.fhs;
        profiles.default.extensions = with pkgs.vscode-extensions; [
          jnoortheen.nix-ide
          brettm12345.nixfmt-vscode
          charliermarsh.ruff
          vscodevim.vim
          rust-lang.rust-analyzer
        ];
      };

      feh = {
        # Light-weight image viewer
        enable = true;
        keybindings = {
          zoom_in = "plus";
          zoom_out = "minus";
          scroll_up = "i";
          scroll_down = "k";
          scroll_right = "j";
          scroll_left = "l";
          delete = "D";
          next_img = "Right";
          prev_img = "Left";
          remove = "d Delete";
          toggle_filenames = "I";
          toggle_info = "i";
          zoom_default = "0";
          zoom_fit = "C-0";
          toggle_fullscreen = "f";
          save_filelist = "F";
        };
      };
    };

    services = {
      # Run this command above:
      # cd ~/Pictures && git clone git@github.com:lxl66566/wallpaper.git
      random-background = {
        enable = true;
        imageDirectory = "%h/Pictures/wallpaper";
        interval = "6h";
      };
      # https://nix-community.github.io/home-manager/options.xhtml#opt-services.activitywatch.watchers
      # https://docs.activitywatch.net/en/latest/configuration.html
      activitywatch = {
        enable = true;
        # package = pkgs.aw-server-rust;
        package = pkgs.activitywatch;
        watchers = {
          aw-watcher-afk = {
            package = pkgs.activitywatch;
            settings = {
              timeout = 180;
              poll_time = 2;
            };
          };
          aw-watcher-window = {
            package = pkgs.activitywatch;
            settings = {
              exclude_title = false;
              poll_time = 1;
            };
          };
        };
        settings = {
          timeout = 180;
        };
      };
    };
  };
}
