{
  pkgs,
  lib,
  features,
  username,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    waybar
  ];

  programs.niri.enable = true;
}
