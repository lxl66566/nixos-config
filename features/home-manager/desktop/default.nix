{
  lib,
  pkgs,
  inputs,
  config,
  ...
}:

{
  imports = [
    inputs.plasma-manager.homeManagerModules.plasma-manager
    ../../../others/plasma.nix
    ../../../others/eye-protection.nix
    ./niri.nix
  ];

  home.file = {
    ".config/mpv".source = config.lib.file.mkOutOfStoreSymlink ../../config/mpv;
    ".config/niri/config.kdl".source = config.lib.file.mkOutOfStoreSymlink ../../config/niri.kdl;
  };

  home.packages = with pkgs; [
    ayugram-desktop
    kdePackages.yakuake
    kdePackages.spectacle
    anki
    jellyfin-ffmpeg
    losslesscut-bin # lossless video/audio editing
    qq
    wechat-uos
    onlyoffice-desktopeditors
    # flameshot # many bugs!
    fsearch # fast file search
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
    aria2
    # flatpak
    # flatpak-builder
  ];

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

  # https://github.com/emersion/mako: A lightweight Wayland notification daemon
  # services.mako = {
  #   enable = true;
  # };
}
