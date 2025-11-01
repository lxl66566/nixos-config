{
  pkgs,
  lib,
  username,
  features,
  ...
}:
{
  imports = [

  ]
  ++ (lib.optionals (!features.mini) [ ./neovim.nix ])
  ++ (lib.optionals (!features.server.enable) [ ./terminal ]);
}
