# NixOS configuration for lxl66566. 
# You can find the lastest version in https://github.com/lxl66566/nixos-config.

{
  config,
  lib,
  pkgs,
  ...
}@args:
{
  imports = [
    ./hardware-configuration.nix
    ./others/vm.nix
  ];

  # region hardware

  hardware = {
    enableAllFirmware = true;
    cpu.intel.updateMicrocode = true;
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        intel-media-driver # LIBVA_DRIVER_NAME=iHD
        intel-ocl
        intel-vaapi-driver # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
        intel-compute-runtime
        vaapiVdpau
        libvdpau-va-gl
        mesa
        nvidia-vaapi-driver
        nv-codec-headers-12
        vpl-gpu-rt
      ];
      extraPackages32 = with pkgs.pkgsi686Linux; [
        intel-media-driver
        intel-vaapi-driver
        vaapiVdpau
        mesa
        libvdpau-va-gl
      ];
    };
    bluetooth = {
      enable = true; # enables support for Bluetooth
      powerOnBoot = false; # powers up the default Bluetooth controller on boot
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
      "vm.swappiness" = 30;
      "net.ipv4.tcp_min_snd_mss" = 536;
      "net.ipv4.tcp_congestion_control" = "bbr";
      "net.ipv6.conf.all.disable_ipv6" = 1;
      "net.ipv6.conf.default.disable_ipv6" = 1;
      "net.ipv6.conf.tun0.disable_ipv6" = 1;
    };
    # kernelPackages = pkgs.linuxPackages_zen;
    kernelModules = lib.mkAfter [
      "kvm-intel"
      "tcp_bbr"
      "coretemp"
    ];
    kernelParams = [
      "nvidia_drm.modeset=1"
      "nvidia_drm.fbdev=1"
      "acpi_enforce_resources=lax"
    ];
    supportedFilesystems = [ "ntfs" ];
    tmp = {
      # https://github.com/NixOS/nixpkgs/blob/nixos-24.05/nixos/modules/system/boot/tmp.nix
      useTmpfs = true;
      tmpfsSize = "80%";
    };
  };
  powerManagement.cpuFreqGovernor = "ondemand";
  networking = {
    hostName = "absx";
    networkmanager.enable = true;
    firewall.enable = false;
    # enableIPv6 = false;
    # proxy.default = "http://127.0.0.1:20172/";
    # proxy.noProxy = "127.0.0.1,localhost,internal.domain";

    # use https://tool.chinaz.com/dns/ to info host.
    extraHosts = ''
      185.199.110.133 raw.githubusercontent.com
      104.244.42.65 twitter.com
    '';
  };
  zramSwap = {
    enable = true;
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
      powerManagement.cpuFreqGovernor = lib.mkForce "powersave";
      powerManagement.powertop.enable = lib.mkForce true;
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
  system.activationScripts.binbash = {
    deps = [ "binsh" ];
    text = ''
      ln -sfn /bin/sh /bin/bash
    '';
  };

  # region nix

  nixpkgs = {
    config = {
      allowUnfree = true;
      packageOverrides = pkgs: {
        nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
          inherit pkgs;
        };
      };
    };
  };
  nix.settings = {
    trusted-users = [ "absx" ];
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    warn-dirty = false;
    builders-use-substitutes = true;
    substituters = lib.mkBefore [
      "https://mirror.sjtu.edu.cn/nix-channels/store"
      "https://mirrors.ustc.edu.cn/nix-channels/store"
      "https://mirrors.cernet.edu.cn/nix-channels/store"
    ];
  };
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 15d";
  };

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
    ipafont
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
      # LANG = defaultLocale;
      # LC_ALL = defaultLocale;
    };
    inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5.addons = with pkgs; [
        fcitx5-rime
        fcitx5-chinese-addons
        fcitx5-mozc
        fcitx5-gtk
        fcitx5-configtool
      ];
      # type = "ibus";
      # ibus.engines = with pkgs.ibus-engines; [
      #   rime
      #   libpinyin
      # ];
    };
  };

  # region services

  services.btrfs.autoScrub = {
    enable = true;
    interval = "15 days";
  };
  services.xserver = {
    enable = true;
    videoDrivers = lib.mkBefore [ "nvidia" ];
  };
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
    settings.PermitRootLogin = "no";
  };
  services.libinput.enable = true;
  services.pipewire = {
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
  # systemd.services.v2raya = {
  #   description = "Run v2raya on startup";
  #   script = "${pkgs.v2raya}/bin/v2rayA";
  #   wantedBy = [ "multi-user.target" ];
  # };
  services.locate = {
    package = pkgs.plocate;
    enable = true;
    localuser = null;
  };
  services.dae = {
    enable = true;
    configFile = ./config/absx.dae;
    assets = with pkgs; [
      v2ray-geoip
      v2ray-domain-list-community
    ];
    # disableTxChecksumIpGeneric = true;
  };
  services.tlp = {
    enable = true;
    settings = {
      USB_AUTOSUSPEND = 0;
      RUNTIME_PM_ON_AC = "auto";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      PLATFORM_PROFILE_ON_BAT = "low-power";
      CPU_BOOST_ON_BAT = 0;
      CPU_HWP_DYN_BOOST_ON_BAT = 0;
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      PLATFORM_PROFILE_ON_AC = "performance";
    };
  };
  services.power-profiles-daemon.enable = false;
  services.thermald.enable = true;
  services.onedrive.enable = false;
  services.vnstat.enable = true;

  systemd.sleep.extraConfig = ''
    AllowSuspend=yes
    AllowHibernation=yes
    AllowHybridSleep=yes
    AllowSuspendThenHibernate=no
    HibernateDelaySec=1h
  '';
  security.rtkit.enable = true;

  # region Users and Root

  users.users.absx = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    shell = pkgs.fish;
    password = "1";
  };
  environment = {
    systemPackages = with pkgs; [
      busybox
      vim
      git
      wget
      curl
      file
      which
      tree
      gnused
      gawk
      yazi
      fzf
      fd
      ncdu
      sd
      ripgrep
      htop
      bat
      lsof
      nixfmt-rfc-style
      python3
      poetry
      iotop
      strace
      trash-cli
      linuxKernel.packages.linux_6_6.cpupower
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
      EDITOR = "nvim";
      SCCACHE_CACHE_SIZE = "50G";
    };
    etc."sysconfig/lm_sensors".text = ''
      HWMON_MODULES="coretemp"
    '';
    persistence."/nix/persistent" = {
      hideMounts = true;
      directories = [
        "/etc/NetworkManager/system-connections"
        "/root"
        "/etc/nixos"
      ];
      files = [
        "/etc/machine-id"
        "/etc/ssh/ssh_host_ed25519_key.pub"
        "/etc/ssh/ssh_host_ed25519_key"
        "/etc/ssh/ssh_host_rsa_key.pub"
        "/etc/ssh/ssh_host_rsa_key"
      ];
    };
    plasma6.excludePackages = with pkgs.kdePackages; [
      plasma-browser-integration
      oxygen
      baloo
      milou
      plasma-workspace-wallpapers
      ocean-sound-theme
      phonon-vlc
      kwallet
      kwallet-pam
      kwalletmanager
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
    platformOptimizations.enable = true;
    extraCompatPackages = with pkgs; [ proton-ge-bin ];
    protontricks = {
      enable = true;
    };
  };
  programs.vim = {
    enable = true;
    defaultEditor = false;
  };
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
  };
  programs.fish.enable = true;
  programs.git = {
    enable = true;
    config = {
      safe.directory = "*";
      core = {
        quotepath = false;
        pager = "delta";
        # excludesfile = "~/.gitignore_g";
      };
      push = {
        default = "current";
        autoSetupRemote = true;
        useForceIfIncludes = true;
      };
      # pull = {
      #   rebase = true;
      # };
      diff = {
        algorithm = "histogram";
        colorMoved = "default";
      };
      init.defaultBranch = "main";
      interactive.diffFilter = "delta --color-only";
      delta.navigate = true;
      merge.conflictstyle = "diff3";
      rebase.autoSquash = true;
      alias = {
        cs = "commit --signoff";
      };
    };
  };
  programs.nix-ld = {
    enable = true;
    libraries =
      with pkgs;
      (steam-run.fhsenv.args.multiPkgs pkgs)
      ++ [
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
