{
  lib,
  inputs,
  pkgs,
  features,
  username,
  config,
  noProxy,
  ...
}:
let
  hostIP = "127.0.0.1";
  proxyUrl = "http://${hostIP}:10450";
in
{
  config = {
    environment = {
      variables = {
        CARGO_BUILD_JOBS = 16;
      };
      etc.hosts.enable = lib.mkForce false; # to edit host file manually
    };

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
  };
  config.home-manager.users."${username}" = {
    home.packages = with pkgs; [
      protobuf
      capnproto
      etcd
      go
      wrk2
    ];
  };
}
