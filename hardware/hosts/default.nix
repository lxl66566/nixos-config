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
        "claw" = ./claw.nix;
        "acck" = ./acck.nix;
      };
    in
    lib.optional (builtins.hasAttr devicename knownDevices) (builtins.getAttr devicename knownDevices);
}
