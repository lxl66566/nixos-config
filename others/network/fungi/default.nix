{
  config,
  pkgs,
  username,
  ...
}:
{
  imports = [
    pkgs.nur.repos.lxl66566.modules.fungi
  ];
  services.fungi = {
    enable = true;
    configFile = ./config.toml;
  };
}
