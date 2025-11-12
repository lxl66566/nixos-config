{
  pkgs,
  lib,
  inputs,
  username,
  ...
}:
{
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
    imports = [
      inputs.plasma-manager.homeModules.plasma-manager
      ./plasma-manager.nix
      ../eye-protection.nix
    ];

    home.packages = with pkgs; [
      kdePackages.yakuake
      kdePackages.spectacle
    ];
  };
}
