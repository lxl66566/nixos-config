# System76 scheduler (not actually a scheduler, just a renice daemon) for improved responsiveness
{
  lib,
  pkgs,
  username,
  features,
  config,
  inputs,
  ...
}:
let
  hasNiri = builtins.elem "niri" features.desktop;
in
{
  services.system76-scheduler = {
    enable = true;
    assignments = {
      games.matchers = [ "osu!" ];
    };
  };

  services.system76-scheduler-niri.enable = hasNiri;
}
