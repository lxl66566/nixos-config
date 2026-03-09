# https://github.com/Aleksanaa/mybar
{
  lib,
  pkgs,
  username,
  inputs,
  ...
}:

{
  environment.systemPackages = [ inputs.mybar.packages.x86_64-linux.default ];
  home-manager.users.${username} = {
    home.packages = with pkgs; [
      papirus-icon-theme
      adwaita-icon-theme
    ];
    programs.niri.settings.spawn-at-startup = lib.mkAfter [
      { argv = [ "mybar" ]; }
    ];
  };
}
