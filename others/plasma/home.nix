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
}
