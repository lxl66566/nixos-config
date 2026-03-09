{
  lib,
  inputs,
  pkgs,
  ...
}:
{
  imports = with inputs.nix-gaming.nixosModules; [
    pipewireLowLatency
  ];
  programs = {
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      gamescopeSession.enable = true;
      # platformOptimizations.enable = true;
      extraCompatPackages = with pkgs; [ proton-ge-bin ];
      protontricks = {
        enable = true;
      };
    };
  };
  environment.systemPackages = with pkgs; [
    # proton-ge-bin
    # wine        # 32 bit only
    # wine64      # 64 bit only
    wineWow64Packages.staging # 32bit + 64bit in one prefix. most widely used
    winetricks
    # DO NOT USE samba4Full
    samba # Standard Windows interoperability suite of programs for Linux and Unix
    # bottles # not usable in 20250723
    soundtouch
    (lutris.override {
      extraLibraries = pkgs: [

      ];
    })
  ];
}
