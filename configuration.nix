# NixOS configuration for lxl66566. 
# You can find the lastest version in https://github.com/lxl66566/nixos-config.

{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [ ./hardware-configuration.nix ];

  # region hardware

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
    };
    bluetooth = {
      enable = true; # enables support for Bluetooth
      powerOnBoot = true; # powers up the default Bluetooth controller on boot
    };
  };

  # region boot&network
  boot = {
    loader = {
      efi.canTouchEfiVariables = true;
      efi.efiSysMountPoint = "/boot";
      grub = {
        enable = true;
        devices = [ "nodev" ];
        efiSupport = true;
        useOSProber = true;
        default = "saved";
      };
      timeout = 15;
      systemd-boot.enable = false;
    };
    kernel.sysctl = {
      "kernel.sysrq" = 1;
      "vm.swappiness" = 10;
    };
    # DO NOT CHANGE KERNEL! Otherwise your system may break due to NVIDIA driver.
    # kernelPackages = pkgs.linuxPackages_zen;
    kernelModules = lib.mkAfter [ ];
    supportedFilesystems = [ "ntfs" ];
  };

  specialisation = {
    on-the-go.configuration = {
      system.nixos.tags = [ "on-the-go" ];
      hardware.nvidia = {
        prime.offload.enable = lib.mkForce true;
        prime.offload.enableOffloadCmd = lib.mkForce true;
        prime.sync.enable = lib.mkForce false;
        powerManagement.finegrained = lib.mkForce true;
      };

    };
  };

  networking.hostName = "absx";
  networking.networkmanager.enable = true;
  networking.firewall.enable = false;
  networking.proxy.default = "http://127.0.0.1:20172/";
  networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # region fonts and ime

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    source-code-pro
    source-han-sans
    source-han-serif
    sarasa-gothic
  ];
  fonts.fontconfig = {
    defaultFonts = {
      emoji = [ "Noto Color Emoji" ];
      monospace = [
        "Fira Code"
        "Noto Sans Mono CJK SC"
        "Sarasa Mono SC"
        "DejaVu Sans Mono"
      ];
      sansSerif = [
        "Fira Code Sans"
        "Noto Sans CJK SC"
        "Source Han Sans SC"
        "DejaVu Sans"
      ];
      serif = [
        "Fira Code Serif"
        "Noto Serif CJK SC"
        "Source Han Serif SC"
        "DejaVu Serif"
      ];
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
      LANG = "en_SG.UTF-8";
      LC_ALL = defaultLocale;
    };
    inputMethod = {
      enabled = "fcitx5";
      fcitx5.addons = with pkgs; [
        fcitx5-chinese-addons
        fcitx5-mozc
        fcitx5-gtk
        fcitx5-rime
        fcitx5-configtool
      ];
      # enabled = "ibus";
      # ibus.engines = with pkgs.ibus-engines; [
      #   rime
      #   libpinyin
      # ];
    };
  };

  # region system settings

  time.hardwareClockInLocalTime = true;
  time.timeZone = "Asia/Shanghai";
  console = {
    earlySetup = true;
    font = "${pkgs.terminus_font}/share/consolefonts/ter-120n.psf.gz";
    packages = with pkgs; [ terminus_font ];
    keyMap = "us";
  };
  nixpkgs.config = {
    allowUnfree = true;
    packageOverrides = pkgs: {
      nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
        inherit pkgs;
      };
    };
  };
  nix.settings = {
    substituters = lib.mkBefore [
      "https://mirror.sjtu.edu.cn/nix-channels/store"
      "https://mirrors.ustc.edu.cn/nix-channels/store"
      "https://mirrors.cernet.edu.cn/nix-channels/store"
    ];
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 15d";
  };

  # region services

  services.xserver.enable = true;
  services.xserver.videoDrivers = lib.mkBefore [ "nvidia" ];
  services.displayManager = {
    sddm.enable = true;
    defaultSession = "plasmax11";
  };
  services.desktopManager = {
    plasma6 = {
      enable = true;
    };
  };
  services.openssh = {
    enable = false;
    settings.PermitRootLogin = "no";
  };
  services.libinput.enable = true;
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    jack.enable = true;
  };
  services.v2raya.enable = true;
  # systemd.services.v2raya = {
  #   description = "Run v2raya on startup";
  #   script = "${pkgs.v2raya}/bin/v2rayA";
  #   wantedBy = [ "multi-user.target" ];
  # };

  systemd.sleep.extraConfig = ''
    AllowSuspend=yes
    AllowHibernation=yes
    AllowHybridSleep=yes
    AllowSuspendThenHibernate=no
    HibernateDelaySec=1h
  '';

  # region Users and Root

  users.users.absx = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    shell = pkgs.fish;
  };
  environment = {
    systemPackages = with pkgs; [
      busybox
      vim
      git
      wget
      curl
      yazi
      zoxide
      fzf
      fd
      ncdu
      sd
      ripgrep
      btop
      htop
      xh
      bat
      lsof
      atuin
      zellij
      nixfmt-rfc-style
      python3
      poetry
      iotop
      strace
      (
        let
          base = pkgs.appimageTools.defaultFhsEnvArgs;
        in
        pkgs.buildFHSUserEnv (
          base
          // {
            name = "fhs";
            targetPkgs =
              pkgs:
              (
                # pkgs.buildFHSUserEnv 只提供一个最小的 FHS 环境，缺少很多常用软件所必须的基础包
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
            runScript = "bash";
            extraOutputsToInstall = [ "dev" ];
          }
        )
      )
    ];
    sessionVariables = rec {
      EDITOR = "vim";
    };
    plasma6.excludePackages = with pkgs.kdePackages; [
      plasma-browser-integration
      oxygen
      baloo
    ];
    localBinInPath = true;
  };

  # region programs

  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    gamescopeSession.enable = true;
    extraCompatPackages = [ pkgs.proton-ge-bin ];
  };
  programs.fish.enable = true;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.11"; # Did you read the comment?
}
