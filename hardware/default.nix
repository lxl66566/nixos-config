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
        "localserver" = ./localserver.nix;
        "main" = ./main.nix;
      };
    in
    lib.optional (builtins.hasAttr devicename knownDevices) (builtins.getAttr devicename knownDevices)
    ++ (lib.optional (features.wsl) <nixos-wsl/modules>)
    ++ (lib.optional (features.server.enable && features.server.type == "remote") ./disko-vps.nix);
}
