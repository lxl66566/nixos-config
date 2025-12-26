{
  config,
  pkgs,
  username,
  ...
}:
{
  # before using this module, please import `pkgs.nur.repos.lxl66566.nixosModules.fungi` in your flake.nix
  services.fungi = {
    enable = true;
    configFile = ./config.toml;
  };
}
