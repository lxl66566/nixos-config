# NixOS configuration of lxl66566, the minimal version is to accelerate reinstallation on livecd.
# You can find the lastest version in https://github.com/lxl66566/nixos-config.

{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [ ./hardware/main.nix ];

  # region hardware

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
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
    };
    kernelParams = [
    ];
    supportedFilesystems = [ "ntfs" ];
    tmp = {
      # https://github.com/NixOS/nixpkgs/blob/nixos-24.05/nixos/modules/system/boot/tmp.nix
      useTmpfs = true;
      tmpfsSize = "80%";
    };
  };

  networking.hostName = "absx";
  networking.networkmanager.enable = true;
  networking.firewall.enable = false;
  # networking.proxy.default = "http://127.0.0.1:20172/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

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
    warn-dirty = false;
  };

  # region services
  services = {
    xserver = {
      enable = true;
      videoDrivers = lib.mkBefore [
        "modesetting"
        "fbdev"
        # "amdgpu"
        # "intel-gpu"
      ];
    };
    dae = {
      enable = true;
      # do not change, it's minimal
      configFile = "/etc/nixos/config/absx.dae";
      assets = with pkgs; [
        v2ray-geoip
        v2ray-domain-list-community
      ];
    };
    libinput.enable = true;
    displayManager = {
      sddm.enable = true;
      defaultSession = "plasmax11";
    };
    desktopManager = {
      plasma6 = {
        enable = true;
      };
    };
  };

  # region Users and Root

  users.users.absx = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "docker"
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
      yazi
      fd
      ncdu
      ripgrep
      htop
      lsof
      nixfmt-rfc-style
      iotop
      impala
      strace
      v2raya
      vscode
      firefox
    ];
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
  programs.vim.defaultEditor = true;
  programs.fish.enable = true;
  programs.git.enable = true;
  system.stateVersion = "24.11"; # Did you read the comment?
}
