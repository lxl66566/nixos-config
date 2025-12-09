{
  self,
  config,
  pkgs,
  lib,
  devicename,
  username,
  features,
  ...
}:
{
  programs.eww = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
    enableZshIntegration = true;
  };

  xdg.configFile = {
    "eww".source = "${self}/config/eww";
  };
}
