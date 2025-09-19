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
      CARGO_BUILD_JOBS = 16;
    };
  };

  # systemd.services.nix-daemon.serviceConfig = {
  #   Environment = "all_proxy=" + proxyUrl;
  # };

  systemd.services.docker.serviceConfig = lib.mkIf (config.virtualisation.docker.enable) {
    Environment = [
      # "HTTP_PROXY=${proxyUrl}"
      # "HTTPS_PROXY=${proxyUrl}"
      "NO_PROXY=${noProxy}"
    ];
  };
  virtualisation.docker.daemon.settings = {
    "insecure-registries" = (import ../../config/docker-insecure-registries.nix);
  };
  services.dae.enable = lib.mkForce false;
  services.v2raya.enable = true;
}
