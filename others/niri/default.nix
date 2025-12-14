# please see https://github.com/Vortriz/awesome-niri
{
  self,
  lib,
  pkgs,
  inputs,
  config,
  devicename,
  username,
  features,
  ...
}:
{
  imports = [
    inputs.niri.nixosModules.niri # system level module for displayManager (sddm), https://github.com/sodiboo/niri-flake/issues/287
    # ./DankMaterialShell.nix # currently used
    # ./noctalia-shell.nix
  ]
  ++ (if features.wsl then [ ./DankMaterialShell.nix ] else [ ./waybar.nix ]); # waybar cannot use in WSL

  services.gnome.gnome-keyring.enable = lib.mkForce false;
  # https://github.com/sodiboo/niri-flake/issues/114
  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };
  security.rtkit.enable = true;
  # so that the portal definitions and DE provided configurations get linked
  environment.pathsToLink = [
    "/share/applications"
    "/share/xdg-desktop-portal"
  ];

  programs.niri.enable = true;
  environment.systemPackages = with pkgs; [
    xwayland-satellite
    xdg-desktop-portal-gtk
    catppuccin-cursors.mochaDark
  ];
  home-manager.users.${username} =
    { config, lib, ... }:
    {
      # https://github.com/sodiboo/niri-flake/blob/main/docs.md
      programs.niri.settings = {
        screenshot-path = "~/Pictures from %Y.%m.%d-%H%M%S.png";
        input = {
          warp-mouse-to-focus.enable = true;
          workspace-auto-back-and-forth = true;
          focus-follows-mouse.enable = true;
          focus-follows-mouse.max-scroll-amount = "0%";
          keyboard = {
            numlock = true;
            repeat-delay = 350;
            repeat-rate = 28;
          };
          touchpad = {
            accel-profile = "flat";
            accel-speed = 0.2;
            drag = true;
            dwt = true;
            disabled-on-external-mouse = true;
            natural-scroll = true;
            scroll-method = "two-finger";
          };
          mouse = {
            accel-profile = "flat";
            accel-speed = -0.14;
          };
        };
        cursor = {
          theme = "catppuccin-mocha-dark-cursors";
          size = 24;
          hide-when-typing = true;
          hide-after-inactive-ms = 3000;
        };
        outputs.DP-1 = {
          enable = true;
          scale = 1.5;
          variable-refresh-rate = "on-demand";
          focus-at-startup = true;
        };
        layout = {
          gaps = 12;
          center-focused-column = "on-overflow";
          always-center-single-column = true;
          preset-column-widths = [
            { proportion = 1. / 3.; }
            { proportion = 1. / 2.; }
            { proportion = 2. / 3.; }
          ];
          default-column-width = {
            proportion = 2. / 3.;
          };
          focus-ring = {
            enable = true;
            width = 2;
            active = {
              color = "#7fc8ff";
            };
            inactive = {
              color = "#505050";
            };
            urgent = {
              color = "#9b0000";
            };
          };
          border.enable = false;
          shadow.enable = false;
        };
        animations.slowdown = 0.5;
        window-rules = [
          {
            matches = [ ];
            geometry-corner-radius = {
              bottom-left = 3.;
              bottom-right = 3.;
              top-left = 3.;
              top-right = 3.;
            };
            clip-to-geometry = true;
          }
        ];
        environment = {
          DISPLAY = ":0";
        };
        binds = with config.lib.niri.actions; {
          "Mod+Shift+Slash".action = show-hotkey-overlay;
          "Mod+R".action.spawn = "foot";
          # "Mod+Space".action.spawn = "fuzzel";
          "Mod+O" = {
            repeat = false;
            action = toggle-overview;
          };
          "Mod+Q" = {
            repeat = false;
            action = close-window;
          };
          "Mod+Left".action = focus-column-left;
          "Mod+Right".action = focus-column-right;
          "Mod+Down".action = focus-window-down;
          "Mod+Up".action = focus-window-up;
          "Mod+H".action = focus-column-left;
          "Mod+L".action = focus-column-right;
          "Mod+J".action = focus-window-down;
          "Mod+K".action = focus-window-up;

          "Mod+Ctrl+Left".action = move-column-left;
          "Mod+Ctrl+Right".action = move-column-right;
          "Mod+Ctrl+Down".action = move-window-down;
          "Mod+Ctrl+Up".action = move-window-up;
          "Mod+Ctrl+H".action = move-column-left;
          "Mod+Ctrl+L".action = move-column-right;
          "Mod+Ctrl+J".action = move-window-down;
          "Mod+Ctrl+K".action = move-window-up;

          "Mod+Shift+Left".action = focus-monitor-left;
          "Mod+Shift+Right".action = focus-monitor-right;
          "Mod+Shift+Down".action = focus-monitor-down;
          "Mod+Shift+Up".action = focus-monitor-up;
          "Mod+Shift+H".action = focus-monitor-left;
          "Mod+Shift+L".action = focus-monitor-right;
          "Mod+Shift+J".action = focus-monitor-down;
          "Mod+Shift+K".action = focus-monitor-up;

          "Mod+Shift+Ctrl+Left".action = move-column-to-monitor-left;
          "Mod+Shift+Ctrl+Right".action = move-column-to-monitor-right;
          "Mod+Shift+Ctrl+Down".action = move-column-to-monitor-down;
          "Mod+Shift+Ctrl+Up".action = move-column-to-monitor-up;
          "Mod+Shift+Ctrl+H".action = move-column-to-monitor-left;
          "Mod+Shift+Ctrl+L".action = move-column-to-monitor-right;
          "Mod+Shift+Ctrl+J".action = move-column-to-monitor-down;
          "Mod+Shift+Ctrl+K".action = move-column-to-monitor-up;

          "Mod+Home".action = focus-column-first;
          "Mod+End".action = focus-column-last;
          "Mod+Ctrl+Home".action = move-column-to-first;
          "Mod+Ctrl+End".action = move-column-to-last;

          "Mod+Page_Down".action.focus-workspace = "down";
          "Mod+Page_Up".action.focus-workspace = "up";
          "Mod+U".action.focus-workspace = "down";
          "Mod+I".action.focus-workspace = "up";
          "Mod+Ctrl+Page_Down".action = move-column-to-workspace-down;
          "Mod+Ctrl+Page_Up".action = move-column-to-workspace-up;
          "Mod+Ctrl+U".action = move-column-to-workspace-down;
          "Mod+Ctrl+I".action = move-column-to-workspace-up;
          "Mod+Shift+Page_Down".action = move-workspace-down;
          "Mod+Shift+Page_Up".action = move-workspace-up;
          "Mod+Shift+U".action = move-workspace-down;
          "Mod+Shift+I".action = move-workspace-up;

          "Mod+WheelScrollDown" = {
            cooldown-ms = 150;
            action = focus-column-right;
          };
          "Mod+WheelScrollUp" = {
            cooldown-ms = 150;
            action = focus-column-left;
          };
          "Mod+Ctrl+WheelScrollDown" = {
            cooldown-ms = 150;
            action = move-column-right;
          };
          "Mod+Ctrl+WheelScrollUp" = {
            cooldown-ms = 150;
            action = move-column-left;
          };

          # Usually scrolling up and down with Shift in applications results in horizontal scrolling; these binds replicate that.
          "Mod+Shift+WheelScrollDown" = {
            cooldown-ms = 150;
            action.focus-workspace = "down";
          };
          "Mod+Shift+WheelScrollUp" = {
            cooldown-ms = 150;
            action.focus-workspace = "up";
          };
          "Mod+Shift+WheelScrollLeft" = {
            cooldown-ms = 150;
            action.focus-workspace = "left";
          };
          "Mod+Shift+WheelScrollRight" = {
            cooldown-ms = 150;
            action.focus-workspace = "right";
          };

          "Mod+1".action.focus-workspace = 1;
          "Mod+2".action.focus-workspace = 2;
          "Mod+3".action.focus-workspace = 3;
          "Mod+4".action.focus-workspace = 4;
          "Mod+5".action.focus-workspace = 5;
          "Mod+6".action.focus-workspace = 6;
          "Mod+7".action.focus-workspace = 7;
          "Mod+8".action.focus-workspace = 8;
          "Mod+9".action.focus-workspace = 9;
          "Mod+Ctrl+1".action.move-column-to-workspace = 1;
          "Mod+Ctrl+2".action.move-column-to-workspace = 2;
          "Mod+Ctrl+3".action.move-column-to-workspace = 3;
          "Mod+Ctrl+4".action.move-column-to-workspace = 4;
          "Mod+Ctrl+5".action.move-column-to-workspace = 5;
          "Mod+Ctrl+6".action.move-column-to-workspace = 6;
          "Mod+Ctrl+7".action.move-column-to-workspace = 7;
          "Mod+Ctrl+8".action.move-column-to-workspace = 8;
          "Mod+Ctrl+9".action.move-column-to-workspace = 9;

          "Mod+BracketLeft".action = consume-or-expel-window-left;
          "Mod+BracketRight".action = consume-or-expel-window-right;

          "Mod+E".action = switch-preset-column-width;
          "Mod+Shift+R".action = switch-preset-window-height;
          "Mod+Ctrl+R".action = reset-window-height;
          "Mod+F".action = maximize-column;
          "Mod+Ctrl+F".action = expand-column-to-available-width;
          "Mod+Shift+F".action = fullscreen-window;
          "Mod+C".action = center-column;
          "Mod+Ctrl+C".action = center-visible-columns;
          "Mod+W".action = toggle-column-tabbed-display;

          "Mod+Minus".action.set-column-width = "-10%";
          "Mod+Equal".action.set-column-width = "+10%";
          "Mod+Shift+Minus".action.set-window-height = "-10%";
          "Mod+Shift+Equal".action.set-window-height = "+10%";

          # "Print".action = screenshot-screen;
          # "Alt+Print".action = screenshot-window;

          "Mod+Shift+E".action = quit;
          "Ctrl+Alt+Delete".action = quit;
          "Mod+Shift+P".action = power-off-monitors;
        };
      };
    };
}
