{
  lib,
  inputs,
  pkgs,
  ...
}:
{
  imports = with inputs.nix-gaming.nixosModules; [
    pipewireLowLatency
    platformOptimizations
  ];
  programs = {
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      gamescopeSession.enable = true;
      platformOptimizations.enable = true;
      extraCompatPackages = with pkgs; [ proton-ge-bin ];
      protontricks = {
        enable = true;
      };
    };
  };
  environment.systemPackages = with pkgs; [
    # proton-ge-bin
    wine
    wine64
    winetricks
    # DO NOT USE samba4Full
    samba # Standard Windows interoperability suite of programs for Linux and Unix
    # bottles # not usable in 20250723
    (lutris.override {
      extraLibraries = pkgs: [

      ];
    })
  ];
}
