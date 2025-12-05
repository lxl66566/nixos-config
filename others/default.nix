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
  ++ (lib.optionals (!features.server.enable) [ ./terminal ]);
}
