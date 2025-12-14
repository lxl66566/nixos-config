{
  pkgs,
  lib,
  username,
  features,
  inputs,
  ...
}:
{
  imports = [
    inputs.catppuccin.nixosModules.catppuccin
  ];

  catppuccin.enable = true;

  home-manager.users.${username} = {
    imports = [ inputs.catppuccin.homeModules.catppuccin ];
    catppuccin.enable = true;
  };

}
