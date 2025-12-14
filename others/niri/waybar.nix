# original from https://paste.aleksana.moe/cVCjVCVAMXa.nix, and changed by me
{
  lib,
  pkgs,
  username,
  ...
}:

let
  nixLogo = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
in
{
  home-manager.users.${username} = {
    home.packages = [ pkgs.nerd-fonts.jetbrains-mono ];
    programs.niri.settings.spawn-at-startup = lib.mkAfter [
      { argv = [ "waybar" ]; }
    ];
    programs.waybar = {
      enable = true;
      package = pkgs.waybar;
      settings = {
        mainbar = {
          spacing = 6;
          layer = "top";

          modules-left = [
            "custom/menu"
            "niri/workspaces"
            "cpu"
            "memory"
            "temperature"
            "network"
          ];
          modules-center = [
            "clock"
            "custom/notification"
          ];
          modules-right = [
            "custom/playing"
            "backlight"
            "pulseaudio"
            "idle_inhibitor"
            "battery"
            "power-profiles-daemon"
            "tray"
          ];

          "custom/menu" = {
            format = "  ";
            tooltip = false;
            on-click = "${lib.getExe pkgs.better-control}";
          };

          "niri/workspaces" = { };

          "cpu" = {
            interval = 1;
            format = " {usage}% {avg_frequency}G";
          };

          "memory" = {
            interval = 2;
            format = "󰄦 {used:0.1f}/{total:0.1f}G";
          };

          "temperature" = {
            interval = 1;
            hwmon-path = "/sys/class/hwmon/hwmon2/temp1_input";
            format = " {temperatureC}°C";
          };

          "idle_inhibitor" = {
            format = "{icon} {status}";
            format-icons = {
              "activated" = "󰒳";
              "deactivated" = "󰒲";
            };
          };

          "custom/playing" = {
            exec = pkgs.writeShellScript "getplaying" ''
              ${pkgs.playerctl}/bin/playerctl metadata --follow --format '{{ status }} {{ trunc(title,8) }}|{{ trunc(artist,8) }}' | ${pkgs.gnused}/bin/sed -u 's/Playing//;s/Paused//;s/Stopped |$//'
            '';
            on-click = pkgs.writeShellScript "switch" ''
              ${pkgs.playerctl}/bin/playerctl play-pause;
            '';
            on-scroll-up = pkgs.writeShellScript "scrollup" ''
              ${pkgs.playerctl}/bin/playerctl position 5-
            '';
            on-scroll-down = pkgs.writeShellScript "scrollup" ''
              ${pkgs.playerctl}/bin/playerctl position 5+
            '';
          };

          # switch to mpris when playerctld is ready
          # "mpris" = {
          #   format = "{status_icon} {dynamic}";
          #   dynamic-order = [ "title" "artist" ];
          #   dynamic-separator = " ";
          #   title-len = 8;
          #   artist-len = 8;
          #   status-icons = {
          #     playing = "";
          #     paused = "";
          #     stopped = "󰙦";
          #   };
          # };

          "clock" = {
            interval = 1;
            align = 0;
            rotate = 0;
            tooltip-format = "<tt><big>{calendar}</big></tt>";
            format = "  {:%a %Y-%m-%d %H:%M:%S}";
          };

          "custom/notification" = {
            tooltip = false;
            format = "{icon}";
            format-icons = {
              notification = " ";
              none = "";
              dnd-notification = " ";
              dnd-none = "";
            };
            return-type = "json";
            exec = pkgs.writeShellScript "execSwayNC" ''
              ${pkgs.swaynotificationcenter}/bin/swaync-client -swb
            '';
            on-click = "${pkgs.swaynotificationcenter}/bin/swaync-client -op";
            on-click-right = pkgs.writeShellScript "dndSwayNC" ''
              if [[ $(${pkgs.swaynotificationcenter}/bin/swaync-client --get-dnd) == true ]]; then
                ${pkgs.swaynotificationcenter}/bin/swaync-client --dnd-off
              else
                ${pkgs.swaynotificationcenter}/bin/swaync-client --dnd-on
              fi
            '';
            escape = true;
          };

          "tray" = {
            icon-size = 16;
            spacing = 10;
          };

          "backlight" = {
            interval = 2;
            align = 0;
            rotate = 0;
            format = "{icon} {percent}%";
            format-icons = [
              "󰛩"
              "󱩑"
              "󱩓"
              "󰛨"
            ];
            smooth-scrolling-threshold = 1;
          };

          "pulseaudio" = {
            format = "{icon} {volume}%";
            format-muted = " Mute";
            format-bluetooth = " {volume}% {format_source}";
            format-bluetooth-muted = " Mute";
            format-source = " {volume}%";
            format-source-muted = "";
            format-icons = {
              headphone = "";
              hands-free = "";
              headset = "";
              phone = "";
              portable = "";
              car = "";
              default = [
                ""
                ""
                ""
              ];
            };
            on-click = "${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle";
            on-click-right = pkgs.writeShellScript "switchoutput" ''
              CURRENT_SINK="$(${pkgs.pulseaudio}/bin/pactl get-default-sink)"
              SINK_REGEX='^[[:digit:]]*[[:blank:]]([^ [:blank:]]*)[[:blank:]]'
              SETNEXT=0
              FIRST=""
              RESULT=""
              while read -r line; do
                if [[ "''${line}" =~ ''${SINK_REGEX} ]]; then
                  current="''${BASH_REMATCH[1]}"
                  if [[ "''${current}" =~ ''${CURRENT_SINK} ]]; then
                    SETNEXT=1
                  elif [[ -z "''${FIRST}" ]]; then
                    FIRST="''${current}"
                  elif [[ "''${SETNEXT}" == 1 ]]; then
                    RESULT="''${current}"
                  fi
                fi
              done <<<"$(${pkgs.pulseaudio}/bin/pactl list short sinks)"
              if [[ -z "''${RESULT}" ]]; then
                RESULT="''${FIRST}"
              fi
              ${pkgs.pulseaudio}/bin/pactl set-default-sink "''${RESULT}"
            '';
            smooth-scrolling-threshold = 1;
          };

          "network" = {
            interval = 1;
            format-disconnected = "󰤯 Disconnected";
            format-disabled = "󰤮 Disabled";
            format = " {bandwidthUpBytes}  {bandwidthDownBytes}";
            tooltip-format = "󰩠 {ifname} via {gwaddr}";
            tooltip-format-wifi = "󰀂 {essid}/{signalStrength}% via {gwaddr}";
          };

          "battery" = {
            interval = 50;
            full-at = 100;
            design-capacity = false;
            states = {
              good = 95;
              warning = 30;
              critical = 15;
            };
            format = "{icon} {capacity}%";
            format-charging = "󰂄 {capacity}%";
            format-plugged = " {capacity}%";
            format-alt = "{time} {power}W";
            format-icons = [
              "󱃍"
              "󰁺"
              "󰁻"
              "󰁼"
              "󰁽"
              "󰁾"
              "󰁿"
              "󰂀"
              "󰂁"
              "󰂂"
              "󱟢"
            ];
            format-time = "󰔛 {H}h,{M}min ";
            tooltip = true;
          };

          "power-profiles-daemon" = {
            format = "󱤎 {icon}";
            format-icons = {
              "default" = "";
              "performance" = "";
              "balanced" = "";
              "power-saver" = "";
            };
          };
        };
      };
      style = ''
        *{font-weight:700;font-size:12px;font-family:JetBrainsMono Nerd Font Propo,Noto Sans CJK SC,sans-serif}
        window#waybar{background:transparent}
        window#waybar>box{border-radius:8px;margin:4px 8px 4px 8px;padding-right:4px;background-color:@base;opacity:0.95;box-shadow:0 0 2px 1px @surface0}
        #backlight{color:@pink}
        #battery{color:@flamingo}
        #clock{color:@green}
        #cpu{color:@sky}
        #memory{color:@red}
        #temperature{color:@teal}
        #tray>.passive{-gtk-icon-effect:dim}
        #pulseaudio{color:@peach}
        #pulseaudio.bluetooth{color:@peach}
        #pulseaudio.muted{color:@subtext1}
        #network{color:@rosewater}
        #network.disabled,#network.disconnected{color:@subtext1}
        #custom-menu{margin-left:6px;padding:2px 6px;background-image:url('${nixLogo}');background-position:center;background-repeat:no-repeat;background-size:contain;}
        #power-profiles-daemon{color:@lavender}
        #custom-playing{color:@pink}
        #custom-notification{color:@yellow}
        #idle_inhibitor{color:@mauve}
        #workspaces button{color:@text;margin:6px 0;padding:2px 4px;border-radius:8px;background:none;border:none}
        #workspaces button.active{border:2px solid @blue;padding:0 8px;border-radius:8px}
        #workspaces button:hover{box-shadow:none;text-shadow:none;transition:none;background-color:@surface0}
        #idle_inhibitor,#custom-notification,#custom-playing,#power-profiles-daemon,#custom-updater,#custom-weather{margin:6px 0;padding:2px 8px;border-radius:8px;background-color:@surface0}
        #backlight,#battery,#clock,#cpu,#memory,#mode,#mpd,#network,#pulseaudio,#temperature,#tray{margin:6px 0;padding:2px 8px;border-radius:8px;background-color:@surface0}
      '';
    };
  };
}
