{
  config,
  pkgs,
  inputs,
  lib,
  devicename,
  username,
  features,
  ...
}:
{
  home-manager.users.${username} = {
    imports = [
      inputs.dankMaterialShell.homeModules.dankMaterialShell.default
      inputs.dankMaterialShell.homeModules.dankMaterialShell.niri
    ];

    programs.dankMaterialShell = {
      enable = true;
      quickshell.package = pkgs.quickshell;
      systemd = {
        enable = true; # Systemd service for auto-start
        restartIfChanged = true; # Auto-restart dms.service when dankMaterialShell changes
      };
      niri = {
        enableKeybinds = true; # https://github.com/AvengeMedia/DankMaterialShell/blob/master/distro/nix/niri.nix
        enableSpawn = true; # Auto-start DMS with niri
      };
      enableSystemMonitoring = true; # System monitoring widgets (dgop)
      enableClipboard = true; # Clipboard history manager
      enableVPN = false; # VPN management widget
      enableBrightnessControl = true; # Backlight/brightness controls
      enableColorPicker = true; # Color picker tool
      enableDynamicTheming = true; # Wallpaper-based theming (matugen)
      enableAudioWavelength = false; # Audio visualizer (cava)
      enableCalendarEvents = true; # Calendar integration (khal)
      enableSystemSound = true; # System sound effects
    };
  };
}
