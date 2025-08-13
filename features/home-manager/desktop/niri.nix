{
  pkgs,
  lib,
  features,
  username,
  ...
}:
{
  home.file = {
    ".config/niri/config.kdl".source = ./config/niri.kdl;
  };
  programs = {
    waybar = {
      enable = true;
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
    alacritty = {
      enable = true;
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
}
