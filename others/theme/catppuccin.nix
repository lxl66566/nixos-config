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

    # my vscode settings is not in nix, and catppuccin will break your settings
    # so i have to disable it and set the theme manually by:
    #
    # "workbench.colorTheme": "Catppuccin Mocha",
    # "catppuccin.accentColor": "mauve",
    # "editor.semanticHighlighting.enabled": true,
    # "terminal.integrated.minimumContrastRatio": 1,
    # "window.titleBarStyle": "custom",
    # "workbench.iconTheme": "catppuccin-mocha"
    catppuccin.vscode.profiles.default.enable = lib.mkForce false;
  };

}
