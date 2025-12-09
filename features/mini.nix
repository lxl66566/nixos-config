{
  self,
  pkgs,
  lib,
  features,
  username,
  inputs,
  ...
}:
{
  disabledModules = [ "${self}/others/neovim.nix" ];

  hardware = {
    graphics.enable = lib.mkForce false;
    graphics.enable32Bit = lib.mkForce false;
  };
  services = {
    locate.enable = lib.mkForce false;
    thermald.enable = lib.mkForce false;
    vnstat.enable = lib.mkForce false;
    openssh.settings.X11Forwarding = lib.mkForce false;
  };
  programs = {
    mtr.enable = lib.mkForce false;
    gnupg.agent.enable = lib.mkForce false;
  };
  virtualisation = {
    docker.enable = lib.mkForce false;
  };

  # region home-manager

  home-manager.users.${username} = {
    programs = {
      atuin.enable = lib.mkForce false;
      starship.enable = lib.mkForce false;
      bat.enable = lib.mkForce false;
      btop.enable = lib.mkForce false;
      feh.enable = lib.mkForce false;
    };
  };
}
