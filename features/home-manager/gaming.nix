{
  lib,
  pkgs,
  ...
}:

{
  home.packages = with pkgs; [
    # osu-lazer-bin
    # (callPackage ./mynixpkgs/libtas.nix { }) # libtas
  ]
  # ++ (with nix-gaming.packages.${pkgs.system}; [ osu-stable ])
  ;
}
