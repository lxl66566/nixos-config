{
  lib,
  pkgs,
  inputs,
  config,
  features,
  useBtrfs,
  ...
}:

{
  imports = [
    inputs.stylix.homeModules.stylix
  ];
  home.file = {
    ".config/mpv".source = ../../config/mpv;
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
      enable = !features.mini;
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
}
