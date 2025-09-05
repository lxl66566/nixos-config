# please see https://github.com/Vortriz/awesome-niri
{
  lib,
  ...
}:
{
  programs.niri.enable = true;
  services.gnome.gnome-keyring.enable = lib.mkForce false;

  fonts.fontconfig.defaultFonts.monospace = lib.mkAfter [
    "Maple Mono NF CN"
  ];
}
