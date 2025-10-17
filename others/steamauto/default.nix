{ config, pkgs, ... }:

let
  steamauto-src = pkgs.fetchFromGitHub {
    owner = "lxl66566";
    repo = "Steamauto";
    rev = "a9b21e676bd6a8394005007f622621a93a6e1590";
    sha256 = "sha256-JYO9ZDc3IDiHfjduIgJi2xDEWQZDjxw4OD1LAqox/iI=";
  };
  config-src = pkgs.mylib.configToStore ./config/config.json5;
  steam-config-src = pkgs.mylib.configToStore ./config/steam_account_info.json5;
  rsakey-src = pkgs.mylib.configToStore ./config/rsakey.txt;
  dest = "/var/lib/steamauto";
in
{
  users.groups.steamauto = { };
  users.users.steamauto = {
    description = "System user for the Steamauto service";
    isSystemUser = true;
    group = "steamauto";
  };

  systemd.services.steamauto = {
    description = "Steamauto Service";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "simple";
      User = "steamauto";
      Group = "steamauto";

      # 使用 systemd 的 StateDirectory 功能，这会自动创建 /var/lib/steamauto
      # 并设置正确的权限。
      StateDirectory = "steamauto";

      # 将工作目录设置为这个可写的状态目录
      WorkingDirectory = dest;

      # 启动前执行：将我们构建的、包含配置的源码从只读的 Nix Store
      # 复制到可写的状态目录中。
      ExecStartPre = [
        "${pkgs.coreutils}/bin/cp -rnT ${steamauto-src} ${dest}"
        "${pkgs.coreutils}/bin/mkdir -p ${dest}/config"
        "${pkgs.coreutils}/bin/cp -f ${config-src} ${dest}/config/config.json5"
        "${pkgs.coreutils}/bin/cp -f ${steam-config-src} ${dest}/config/steam_account_info.json5"
        "${pkgs.coreutils}/bin/cp -f ${rsakey-src} ${dest}/config/rsakey.txt"
      ];

      ExecStart = ''
        ${pkgs.uv}/bin/uv run --python ${pkgs.python3}/bin/python3 Steamauto.py
      '';

      Environment = [
        "PATH=${pkgs.lib.makeBinPath [ pkgs.coreutils ]}"
        "UV_CACHE_DIR=${dest}/.cache/uv"
        "LD_LIBRARY_PATH=${pkgs.lib.makeLibraryPath [ pkgs.stdenv.cc.cc.lib ]}"
      ];
      Restart = "on-failure";
      RestartSec = "60s";
    };
  };
}
