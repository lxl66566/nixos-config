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
    (builtins.getAttr devicename {
      "localserver" = ./localserver.nix;
      "main" = ./main.nix;
    })
  ]
  ++ (lib.optional (features.wsl) <nixos-wsl/modules>);
}
