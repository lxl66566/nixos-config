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
  ++ (lib.optionals (!features.server.enable) [ ./terminal ])
  ++ (lib.optionals (features.programming) [ ./sccache.nix ]);

}
