{
  pkgs,
  lib,
  inputs,
  username,
  ...
}:
{
  imports = [
    ./plasma-manager.nix
  ];
  services = {
    desktopManager = {
      plasma6 = {
        enable = true;
      };
    };
  };

  environment = {
    plasma6.excludePackages = with pkgs.kdePackages; [
      plasma-browser-integration
      oxygen
      baloo
      baloo-widgets
      milou
      plasma-workspace-wallpapers
      ocean-sound-theme
      phonon-vlc
      kwallet
      kwallet-pam
      kwalletmanager
      elisa
      kio-gdrive
    ];
    etc."xdg/baloofilerc".source = (pkgs.formats.ini { }).generate "baloorc" {
      "Basic Settings" = {
        "Indexing-Enabled" = false;
      };
    };
  };

  home-manager.users.${username} = {
    home.packages = with pkgs; [
      kdePackages.yakuake
      kdePackages.spectacle
    ];
  };
}
