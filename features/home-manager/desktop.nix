{
  lib,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    inputs.plasma-manager.homeManagerModules.plasma-manager
    ../../others/plasma.nix
    ../../others/eye-protection.nix
  ];

  home.file = {
    ".config/mpv".source = ../../config/mpv;
    ".config/niri/config.kdl".source = ../../config/niri.kdl;
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
    flameshot
    fsearch # fast file search
    # libreoffice-qt6-still
    xclip
    # nvtopPackages.nvidia
    # qpwgraph
    # qbittorrent
    wine
    winetricks
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
    poetry = {
      enable = false;
      settings = {
        virtualenvs.create = true;
        virtualenvs.in-project = true;
      };
    };

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
    fuzzel = {
      # APP launcher
      enable = true;
    };
    alacritty.enable = false;
  };

  # Run this command above:
  # cd ~/Pictures && git clone git@github.com:lxl66566/wallpaper.git
  services.random-background = {
    enable = true;
    imageDirectory = "%h/Pictures/wallpaper";
    interval = "6h";
  };

  # services.activitywatch = {
  #   enable = true;
  #   # package = pkgs.aw-server-rust;
  #   package = pkgs.activitywatch;
  #   watchers = {
  #     aw-watcher-afk = {
  #       package = pkgs.activitywatch;
  #       settings = {
  #         timeout = 300;
  #         poll_time = 2;
  #       };
  #     };
  #     aw-watcher-windows = {
  #       package = pkgs.activitywatch;
  #       settings = {
  #         poll_time = 1;
  #         exclude_title = true;
  #       };
  #     };
  #   };
  #   settings = {
  #     timeout = 180;
  #   };
  # };

  # https://github.com/emersion/mako: A lightweight Wayland notification daemon
  # services.mako = {
  #   enable = true;
  # };
}
