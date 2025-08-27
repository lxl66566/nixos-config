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
      };
    in
    lib.optional (builtins.hasAttr devicename knownDevices) (builtins.getAttr devicename knownDevices)
    ++ (lib.optional (features.wsl) <nixos-wsl/modules>)
    ++ (lib.optional (
      features.server.enable && features.server.type == "remote" && features.server.disko
    ) ./disko-vps.nix)
    ++ (lib.optional (features.server.enable && features.server.type == "remote") ./remote-default.nix);
}
