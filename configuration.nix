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

  # region boot, hardware and network

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
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
  i18n.defaultLocale = "zh_CN.UTF-8";
  i18n.supportedLocales = lib.mkBefore [
    "C.UTF-8/UTF-8"
    "en_US.UTF-8/UTF-8"
    "ja_JP.UTF-8/UTF-8"
    "zh_CN.UTF-8/UTF-8"
  ];
  i18n.inputMethod = {
    # enabled = "fcitx5";
    # fcitx5.addons = with pkgs; [
    #   fcitx5-chinese-addons
    #   fcitx5-mozc
    #   fcitx5-gtk
    #   fcitx5-rime
    # ];
    enabled = "ibus";
    ibus.engines = with pkgs.ibus-engines; [
      rime
      libpinyin
    ];
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
  nix.settings.substituters = lib.mkBefore [
    "https://mirror.sjtu.edu.cn/nix-channels/store"
    "https://mirrors.ustc.edu.cn/nix-channels/store"
    "https://mirrors.cernet.edu.cn/nix-channels/store"
  ];
  nix.extraOptions = ''
    experimental-features = nix-command
  '';
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 15d";
  };

  # region services

  services.xserver.enable = true;
  # services.xserver.videoDrivers = lib.mkAfter [ "nvidia" ];
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
  };
  services.v2raya.enable = true;
  # systemd.services.v2raya = {
  #   description = "Run v2raya on startup";
  #   script = "${pkgs.v2raya}/bin/v2rayA";
  #   wantedBy = [ "multi-user.target" ];
  # };

  # region Users and Root

  users.users.absx = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    packages = with pkgs; [
      vim
      tree
      wget
      floorp
      vscode
      telegram-desktop
      fastfetch
      flameshot
      eza
      nodejs_22
      corepack_22
      kdePackages.yakuake
      rustup
      bottles
      v2raya
      anki
      jellyfin-ffmpeg
    ];
    shell = pkgs.fish;
  };
  environment = {
    systemPackages = with pkgs; [
      vim
      git
      wget
      curl
      nix-search-cli
      yazi
      zoxide
      fzf
      fd
      ncdu
      dust
      sd
      ripgrep
      tldr
      btop
      htop
      xh
      bat
      mtr
      lsof
      atuin
      zellij
      nixfmt-rfc-style
      python3
      starship
    ];
    sessionVariables = rec {
      EDITOR = "vim";
    };
    plasma6.excludePackages = with pkgs.kdePackages; [
      plasma-browser-integration
      oxygen
      baloo
    ];

  };

  # region programs

  xdg.portal.enable = true;
  # xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
  # programs.steam = {
  #   enable = true;
  #   remotePlay.openFirewall = true;
  #   dedicatedServer.openFirewall = true;
  #   gamescopeSession.enable = true;
  #   extraCompatPackages = [ pkgs.proton-ge-bin ];
  # };
  programs.fish = {
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

      atuin init fish | source
      zoxide init fish | source
      starship init fish | source
    '';
    shellAliases = rec {
      e = "vim";
      l = "eza --all --long --color-scale size --binary --header --time-style=long-iso";
      gp = "git pull";
      gc = "git clone --filter=tree:0";
      gfixup = "git commit -a --fixup HEAD && GIT_SEQUENCE_EDITOR=: git rebase -i --autosquash HEAD~2";
      py = "python";
    };
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
