{
  config,
  lib,
  pkgs,
  devicename,
  username,
  features,
  ...
}:
{
  imports =
    let
      knownDevices = {
        "ls" = ./localserver.nix;
        "main" = ./main.nix;
        "rfc" = ./rfc.nix;
        "dedi" = ./dedi.nix;
        "vhs" = ./vhs.nix;
      };
    in
    lib.optional (builtins.hasAttr devicename knownDevices) (builtins.getAttr devicename knownDevices);
}
