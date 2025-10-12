{
  pkgs,
  lib,
  username,
  features,
  ...
}:
{
  imports = [
    ./terminal
  ]
  ++ (lib.optionals (!features.mini) [ ./neovim.nix ]);
}
