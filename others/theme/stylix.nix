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
    inputs.stylix.nixosModules.stylix
  ];

  stylix = {
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
    polarity = "dark";
    targets.gnome-text-editor.enable = false;
  };

  home-manager.users.${username} = {
    imports = [
      inputs.stylix.homeModules.stylix
    ];
  };
}
