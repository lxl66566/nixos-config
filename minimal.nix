# NixOS configuration of lxl66566, the minimal version is to accelerate reinstallation on livecd. 
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
    };
    kernelParams = [
      "nvidia_drm.modeset=1"
      "nvidia_drm.fbdev=1"
    ];
    supportedFilesystems = [ "ntfs" ];
    tmp = {
      # https://github.com/NixOS/nixpkgs/blob/nixos-24.05/nixos/modules/system/boot/tmp.nix
      useTmpfs = true;
      tmpfsSize = "80%";
    };
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
  services.libinput.enable = true;

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
      yazi
      fzf
      fd
      ncdu
      ripgrep
      htop
      lsof
      nixfmt-rfc-style
      iotop
      impala
      strace
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
