{
  config,
  pkgs,
  lib,
  inputs,
  devicename,
  username,
  features,
  ...
}:
{
  imports = [
    inputs.plasma-manager.homeManagerModules.plasma-manager
    ./plasma-manager.nix
    ../eye-protection.nix
  ];

  home.packages = with pkgs; [
    kdePackages.yakuake
    kdePackages.spectacle
  ];
}
