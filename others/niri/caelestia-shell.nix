{
  config,
  pkgs,
  lib,
  devicename,
  username,
  features,
  ...
}:
{
  home.packages = with pkgs; [
    quickshell

    ddcutil
    brightnessctl
    cava
    i2c-tools
    aubio
    app2unit
    libqalculate
    swappy
    grim
    wl-clipboard-rs
    material-symbols
    matugen

    # fonts
    fira-code
    cascadia-code
  ];

  xdg.configFile = {
    "quickshell/niri-caelestia-shell" = {
      source = pkgs.fetchFromGitHub {
        owner = "jutraim";
        repo = "niri-caelestia-shell";
        rev = "86d2cc159023f13d14327427a6addae92c850c4b";
        sha256 = "sha256-WImpLyBwmlXoqqQnV8zkdGamDImhvwDFGzVG0jarwLg=";
      };
      executable = true;
      recursive = true;
    };
  };
}
