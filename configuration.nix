# NixOS configuration for lxl66566.
# You can find the lastest version in https://github.com/lxl66566/nixos-config.

{
  config,
  lib,
  pkgs,
  devicename,
  username,
  features,
  nur,
  ...
}@args:
{
  imports = [
    ./hardware
  ];

  # region boot&network
  boot = lib.mkIf (!features.wsl) {
    initrd.systemd.enable = true;
    loader = {
      efi.canTouchEfiVariables = true;
      efi.efiSysMountPoint = "/boot";
      grub = {
        enable = !config.boot.isContainer;
        devices = lib.mkDefault [ "nodev" ];
        efiSupport = true;
        default = "saved";
        useOSProber = lib.mkDefault false;

      };
      timeout = 15;
      systemd-boot.enable = false;
    };
    kernel.sysctl = {
      "kernel.sysrq" = 1;
      # "kernel.nmi_watchdog" = 0;
      "vm.swappiness" = 130;
      "vm.watermark_boost_factor" = 0;
      "vm.watermark_scale_factor" = 125;
      "vm.page-cluster" = 0;
      "net.core.default_qdisc" = "cake";
      "net.core.netdev_max_backlog" = 16384;
      "net.ipv4.tcp_fastopen" = 3;
      "net.ipv4.tcp_min_snd_mss" = 536;
      "net.ipv4.tcp_congestion_control" = "bbr";
      "net.ipv6.conf.all.disable_ipv6" = 1;
      "net.ipv6.conf.default.disable_ipv6" = 1;
      "net.ipv6.conf.lo.disable_ipv6" = 1;
    };
    kernelPackages = pkgs.linuxPackages_zen;
    kernelModules = lib.mkAfter [
      "tcp_bbr"
    ];
    kernelParams = [
      "sysrq_always_enabled=1"
      "amdgpu.sg_display=0"

      # "nvidia_drm.modeset=1"
      # "nvidia_drm.fbdev=1"
      # "acpi_enforce_resources=lax"
      # "i915.modeset=1"
      # "i915.force_probe=46a6"
    ]
    ++ (lib.optionals features.server.enable [
      "audit=0"
      "net.ifnames=0"
    ]);
    supportedFilesystems = [ "ntfs" ];
    tmp = {
      # https://github.com/NixOS/nixpkgs/blob/nixos-24.05/nixos/modules/system/boot/tmp.nix
      # useTmpfs = true;
      # tmpfsSize = "80%";
      useZram = true;
      zramSettings.zram-size = "ram * 0.7";
    };
  };
  networking = lib.mkIf (!features.wsl) {
    useDHCP = lib.mkDefault true;
    hostName = lib.mkDefault username;
    networkmanager.enable = lib.mkDefault true;
    firewall.enable = lib.mkDefault false;
    # proxy.default = "http://127.0.0.1:20172/";
    # proxy.noProxy = "127.0.0.1,localhost,internal.domain";

    # use https://tool.chinaz.com/dns/ to info host.
    extraHosts = lib.mkDefault ''
      185.199.110.133 raw.githubusercontent.com
      104.244.42.65 twitter.com
    '';
  };
  # systemd.network.enable = true;
  # systemd.network.networks."10-dhcp" = {
  #   matchConfig.Name = [
  #     "en*"
  #     "eth*"
  #     "wl*"
  #   ];
  #   networkConfig.DHCP = "yes";
  # };
  zramSwap = {
    enable = true;
  };

  # specialisation = {
  #   on-the-go.configuration = {
  #     system.nixos.tags = [ "on-the-go" ];
  #     hardware.nvidia = {
  #       prime.offload.enable = lib.mkForce true;
  #       prime.offload.enableOffloadCmd = lib.mkForce true;
  #       prime.sync.enable = lib.mkForce false;
  #       powerManagement.finegrained = lib.mkForce true;
  #     };
  #     powerManagement.cpuFreqGovernor = lib.mkForce "powersave";
  #     powerManagement.powertop.enable = lib.mkForce true;
  #   };
  # };

  # region system settings

  time.hardwareClockInLocalTime = true;
  time.timeZone = lib.mkDefault "Asia/Shanghai";
  documentation.man = {
    generateCaches = false;
    man-db.enable = false;
  };
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
    config = import ./config/nix-config.nix;
    # overlays = [ nur.overlays.default ];
  };
  nix.settings = {
    trusted-users = [ username ];
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    warn-dirty = false;
    # builders-use-substitutes = true;
    substituters = lib.mkBefore [
      "https://mirrors.ustc.edu.cn/nix-channels/store"
      "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
      "https://mirror.sjtu.edu.cn/nix-channels/store"
      "https://cache.garnix.io"
      "https://mirrors.cernet.edu.cn/nix-channels/store"
    ];
    trusted-public-keys = [ "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g=" ];
  };
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # region services
  services = {
    btrfs.autoScrub = lib.mkIf (!features.wsl) {
      enable = true;
      interval = "15 days";
    };
    # 为所有可移动的块设备强制 udisks2 使用 sync 挂载选项
    udev.extraRules = ''
      ENV{ID_DRIVE_REMOVABLE}=="1", ENV{UDISKS_MOUNT_OPTIONS_DEFAULTS}+="sync"
    '';
    locate = {
      enable = !features.mini;
      package = pkgs.plocate;
      interval = "daily";
      pruneBindMounts = true;
      prunePaths = [
        "/afs"
        "/media"
        "/mnt"
        "/net"
        "/sfs"
        "/udev"
        "/var/lock"
        "/var/spool"
        "/var/tmp"
      ];
      pruneNames = lib.filter (line: line != "" && !lib.strings.hasPrefix "#" (lib.strings.trim line)) (
        lib.map lib.strings.trim (lib.strings.splitString "\n" (builtins.readFile ./config/.gitignore_g))
      );
    };
    dae = {
      enable = !(features.wsl || features.server.as_proxy);
      configFile = "/etc/nixos/config/absx.dae";
      # dae needs 0600 permission, but we cannot source file with permission.
      # related issue: https://github.com/nix-community/home-manager/issues/3090
      # configFile = "/home/absx/.config/absx_.dae";
      assets = with pkgs; [
        v2ray-geoip
        v2ray-domain-list-community
      ];
      # disableTxChecksumIpGeneric = true;
    };
    # 防止过热的守护进程
    thermald.enable = !features.mini;
    vnstat.enable = !features.mini;
    logrotate.checkConfig = false;
  };

  security.pam.services.sudo.rootOK = true;
  security.rtkit.enable = true;

  # region Users and Root

  users.users.${username} = lib.mkIf (!features.server.enable) {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "docker"
    ];
    shell = pkgs.fish;
    password = "1"; # must be set if you use impermanence
  };
  environment = {
    # etc.machine-id.source = ./info/machine-id;
    systemPackages = (
      with pkgs;
      [
        coreutils
        wget
        fd
        htop
        ripgrep
        lsof
        ncdu
        curl
        file
        which
        tree
        # linuxKernel.packages.linux_6_6.cpupower
        # nix-fast-build # why disable this: not usable.
        # nur.repos.lxl66566.git-simple-encrypt
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
              runScript = "bash";
              extraOutputsToInstall = [ "dev" ];
            }
          )
        )
      ]
      ++ (lib.optionals (!features.mini) [
        # busybox
        gnused # GNU sed
        gawk # GNU awk
        gnutar
        unzip
        nixfmt-rfc-style
        python3
        pciutils
        strace
        fastfetch
        efibootmgr # edit efi boot manager
        ethtool # network card info
        zip
        yazi # TUI file browser
        fzf
        ltrace # intercepts and records dynamic library calls which are called by an executed process and the signals received by that process
        sysstat # Collection of performance monitoring tools for Linux (such as sar, iostat and pidstat)
        dnsutils # `dig` + `nslookup`
        mkpasswd
        gcc
        gnumake
        cmake
        sd
        bat
        iotop
        docker-compose
        lazydocker
      ])
    );
    sessionVariables = rec {
      EDITOR = "nvim";
      SCCACHE_CACHE_SIZE = "50G";
      NIXPKGS_ALLOW_UNFREE = 1;
    };

    persistence."/oldroot" = lib.mkIf features.impermanence {
      hideMounts = true;
      directories = [
        "/etc/NetworkManager/system-connections"
        "/etc/nixos"
        # add this two will break my system!
        # "/etc/shadow"
        # "/etc/passwd"
      ];
      files = [
        "/etc/machine-id"
        "/etc/ssh/ssh_host_ed25519_key.pub"
        "/etc/ssh/ssh_host_ed25519_key"
        "/etc/ssh/ssh_host_rsa_key.pub"
        "/etc/ssh/ssh_host_rsa_key"
      ];
    };
    localBinInPath = true;
  };

  # region programs

  programs.mtr.enable = !features.mini;
  programs.gnupg.agent = {
    enable = !features.mini;
    enableSSHSupport = true;
  };
  programs.fish.enable = true;
  programs.vim = {
    enable = true;
    defaultEditor = lib.mkForce false;
  };
  programs.neovim = {
    enable = !features.mini;
    defaultEditor = true;
  };
  programs.git = {
    enable = true;
  };
  programs.nix-ld.enable = true;

  virtualisation.docker = {
    enable = !features.mini;
    autoPrune = {
      enable = true;
      dates = "weekly";
    };

    # If you want to run the docker daemon in rootless mode, you need to specify
    # either the socket path (using thr DOCKER_HOST environment variable) or the
    # CLI context using `docker context` explicitly.
    # https://docs.docker.com/engine/security/rootless/
    # https://docs.docker.com/engine/security/rootless/#client
    # rootless = {
    #   enable = true;
    #   setSocketVariable = true;
    # };
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
