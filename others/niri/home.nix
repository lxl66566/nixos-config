{
  config,
  pkgs,
  lib,
  devicename,
  username,
  features,
  ...
}@inputs:
{
  imports = [
    # ./DankMaterialShell.nix
    # ./eww.nix
    ./caelestia-shell.nix
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

    # console for niri
    ghostty = {
      enable = true;
      enableFishIntegration = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      # https://ghostty.org/docs/config/reference
      settings = {
        font-size = 10.5;
        font-family = "Fira Code";
      };
    };

    # console for niri
    alacritty = {
      enable = false; # it sucks
      settings = {
        window = {
          decorations = "None"; # Show neither borders nor title bar
          dynamic_padding = true;
          dynamic_title = true;
          opacity = 0.93;
          option_as_alt = "Both"; # Option key acts as Alt on macOS
          startup_mode = "Maximized"; # Maximized window
          padding = {
            x = 5;
            y = 5;
          };
        };
        scrolling = {
          history = 10000;
        };
        selection.save_to_clipboard = true;
        font = {
          bold = {
            family = "Maple Mono NF CN";
          };
          italic = {
            family = "Maple Mono NF CN";
          };
          normal = {
            family = "Maple Mono NF CN";
          };
          bold_italic = {
            family = "Maple Mono NF CN";
          };
          size = 13;
        };
        terminal = {
          # Spawn a nushell in login mode via `bash`
          shell = {
            program = "${pkgs.bash}/bin/bash";
            args = [
              "--login"
              "-c"
              "fish --login --interactive"
            ];
          };
          # Controls the ability to write to the system clipboard with the OSC 52 escape sequence.
          # It's used by zellij to copy text to the system clipboard.
          osc52 = "CopyPaste";
        };
      };
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
}
