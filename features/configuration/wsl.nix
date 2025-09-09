{
  lib,
  inputs,
  pkgs,
  feature,
  username,
  ...
}:
let
  hostIP = "127.0.0.1";
  proxyUrl = "http://${hostIP}:10450";
in
{
  wsl = {
    enable = true;
    defaultUser = username;
  };

  environment.variables = {
    HTTP_PROXY = proxyUrl;
    HTTPS_PROXY = proxyUrl;
    ALL_PROXY = proxyUrl;
  };

  # systemd.services.nix-daemon.serviceConfig = {
  #   Environment = "all_proxy=" + proxyUrl;
  # };
}
