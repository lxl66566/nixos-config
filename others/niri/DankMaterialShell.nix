{
  config,
  pkgs,
  lib,
  devicename,
  username,
  features,
  ...
}@inputs:
{
  home.packages = with pkgs; [
    quickshell
    wl-clipboard-rs
    material-symbols
    matugen

    # fonts
    fira-code
    inter
  ];

  xdg.configFile = {
    "quickshell/DankMaterialShell" = {
      source = pkgs.fetchFromGitHub {
        owner = "AvengeMedia";
        repo = "DankMaterialShell";
        rev = "v0.0.2";
        sha256 = "sha256-BOVdFeuZ+nelst14K6KSzoZtlUu3DBWViAflGCMWVcY=";
      };
      executable = true;
      recursive = true;
    };
  };
}
