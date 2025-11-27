# please see https://github.com/Vortriz/awesome-niri
{
  lib,
  config,
  pkgs,
  inputs,
  devicename,
  username,
  ...
}:
{
  programs.niri.enable = true;
  services.gnome.gnome-keyring.enable = lib.mkForce false;

  fonts.fontconfig.defaultFonts.monospace = lib.mkAfter [
    "Maple Mono NF CN"
  ];

  # imports = [ ./noctalia-shell.nix ];

  home-manager.users.${username} = {
    imports = [
      ./DankMaterialShell.nix
      # ./eww.nix
      # ./caelestia-shell.nix
    ];

    home.file = {
      ".config/niri/config.kdl".source = ../../config/niri.kdl;
    };

    home.packages = with pkgs; [
      xwayland-satellite
      xdg-desktop-portal-gtk

      # auto turn off screen when inactive
      swayidle
      swaylock

      # cursor
      catppuccin-cursors.mochaDark
      # capitaine-cursors
    ];

    programs = {
      # bar for niri
      waybar = {
        enable = false; # it sucks
        settings = {
          mainBar = {
            layer = "top";
            position = "top";
            height = 20;
            output = [
              "eDP-1"
              "HDMI-A-1"
            ];
          };
        };
      };

      # APP launcher for niri
      fuzzel = {
        enable = true;
      };
    };

    services = {
      # https://github.com/emersion/mako: A lightweight Wayland notification daemon
      mako = {
        enable = true;
        settings = {
          sort = "-time";
          layer = "overlay";
          icons = 1;
          default-timeout = 3000;
          background-color = "#303030";
          text-color = "#ebdbb2";
          border-size = 0;
          border-radius = 5;
        };
      };
    };
  };
}
