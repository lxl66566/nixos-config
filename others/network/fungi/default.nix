{
  config,
  pkgs,
  username,
  ...
}:

let
  dest = "/root/.fungi";
  config-src = pkgs.mylib.configToStore ./config.toml;
in
{
  systemd.services.fungi = {
    description = "fungi";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "simple";
      User = "root";
      Group = "root";
      StateDirectory = "fungi";
      # WorkingDirectory = dest;
      ExecStartPre = [
        "${pkgs.coreutils}/bin/mkdir -p ${dest}"
        "-${pkgs.nur.repos.lxl66566.fungi}/bin/fungi --fungi-dir ${dest} init"
        "${pkgs.coreutils}/bin/cp -f ${config-src} ${dest}/config.toml"
      ];

      ExecStart = ''
        ${pkgs.nur.repos.lxl66566.fungi}/bin/fungi --fungi-dir ${dest} daemon
      '';
      Restart = "on-failure";
      RestartSec = "60s";
    };
  };
}
