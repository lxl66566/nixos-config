{
  lib,
  inputs,
  pkgs,
  feature,
  username,
  ...
}:
let
  proxy = "http://127.0.0.1:10450";
in
{
  wsl = {
    enable = true;
    defaultUser = username;
  };

  environment.variables = {
    HTTP_PROXY = proxy;
    HTTPS_PROXY = proxy;
    ALL_PROXY = proxy;
  };

  systemd.services.nix-daemon.serviceConfig = {
    Environment = "all_proxy=" + proxy;
  };
}
