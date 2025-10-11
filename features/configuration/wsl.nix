{
  lib,
  inputs,
  pkgs,
  features,
  username,
  config,
  ...
}:
let
  hostIP = "127.0.0.1";
  proxyUrl = "http://${hostIP}:10450";
  noProxy = "localhost,127.0.0.1,::1,.local,192.168.0.0/16,10.0.0.0/8,172.16.0.0/12";
in
{
  imports = [ ./work.nix ];
  wsl = {
    enable = true;
    defaultUser = username;
  };

  environment = {
    variables = {
      # HTTP_PROXY = proxyUrl;
      # HTTPS_PROXY = proxyUrl;
      # ALL_PROXY = proxyUrl;
      NOPROXY = noProxy;
    };
  };

  # systemd.services.nix-daemon.serviceConfig = {
  #   Environment = "all_proxy=" + proxyUrl;
  # };

  # https://github.com/giltene/wrk2/issues/58
  services.ntp.enable = lib.mkForce false;
  services.timesyncd.enable = false;

  services.dae.enable = lib.mkForce false;
  services.v2raya.enable = true;
}
