# please see https://github.com/Vortriz/awesome-niri
{
  lib,
  ...
}:
{
  programs.niri.enable = true;

  fonts.fontconfig.defaultFonts.monospace = lib.mkAfter [
    "Maple Mono NF CN"
  ];
}
