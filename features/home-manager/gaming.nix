{
  lib,
  pkgs,
  ...
}:

{
  home.packages = with pkgs; [
    # osu-lazer-bin
  ]
  # ++ (with nix-gaming.packages.${pkgs.system}; [ osu-stable ])
  ;
}
