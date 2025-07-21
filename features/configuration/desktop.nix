{
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ../../others/vm.nix
  ];
  hardware = {
    bluetooth = {
      enable = true; # enables support for Bluetooth
      powerOnBoot = false; # powers up the default Bluetooth controller on boot
    };
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        # vpl-gpu-rt
        # intel-media-driver # LIBVA_DRIVER_NAME=iHD
        # intel-ocl
        # intel-vaapi-driver # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
        # intel-compute-runtime
        # vaapiVdpau
        # libvdpau-va-gl
        # mesa
        # nvidia-vaapi-driver
        # nv-codec-headers-12
      ];
      # extraPackages32 = with pkgs.pkgsi686Linux; [
      #   intel-media-driver
      #   intel-vaapi-driver
      #   vaapiVdpau
      #   mesa
      #   libvdpau-va-gl
      # ];
    };
  };

  # region fonts and ime
  fonts.packages = with pkgs; [
    noto-fonts
    # 'noto-fonts-cjk' has been renamed to/replaced by 'noto-fonts-cjk-sans'
    noto-fonts-cjk-serif
    noto-fonts-cjk-sans
    noto-fonts-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    source-code-pro
    source-han-sans
    source-han-serif
    sarasa-gothic
    ipafont
    vistafonts-chs
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
    cache32Bit = true;
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
      sddm.enable = true;
      defaultSession = "plasmax11";
    };
    desktopManager = {
      plasma6 = {
        enable = true;
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

  environment = {
    systemPackages = with pkgs; [

    ];
    plasma6.excludePackages = with pkgs.kdePackages; [
      plasma-browser-integration
      oxygen
      baloo
      baloo-widgets
      milou
      plasma-workspace-wallpapers
      ocean-sound-theme
      phonon-vlc
      kwallet
      kwallet-pam
      kwalletmanager
      elisa
    ];
  };

  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

  programs = {
    niri = {
      enable = false;
    };
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
}
