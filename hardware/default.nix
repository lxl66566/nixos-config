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
  imports = [
    ./hosts
  ]
  ++ (lib.optional (features.wsl) <nixos-wsl/modules>)
  ++ (lib.optional (
    features.server.enable && features.server.type == "remote" && features.server.disko
  ) ./disko-vps.nix)
  ++ (lib.optional (features.server.enable && features.server.type == "remote") ./remote-default.nix);
}
