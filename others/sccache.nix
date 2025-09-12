{
  lib,
  pkgs,
  username,
  features,
  config,
  ...
}:
{
  home-manager.users."${username}".home = {
    packages = with pkgs; [
      sccache
    ];
    file = {
      ".config/sccache/config".text = ''
        server_startup_timeout_ms = 5000
      '';
    };
  };

  environment.variables = {
    SCCACHE_DIR = "~/.cache/sccache"; # needed for wsl to not to use the cache dir on windows (which is slow)
    SCCACHE_CACHE_SIZE = "50G";
    RUSTC_WRAPPER = "sccache";
  };
  # // (
  #   if features.wsl then
  #     {
  #       SCCACHE_SERVER_PORT = "5650"; # use a different port for wsl to avoid conflict with windows sccache
  #       SCCACHE_DIRECT = 0;
  #     }
  #   else
  #     { }
  # );
}
