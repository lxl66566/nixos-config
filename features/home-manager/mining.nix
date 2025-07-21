{
  lib,
  pkgs,
  ...
}:

{
  home.packages = with pkgs; [
    (callPackage ../../mynixpkgs/xmrig.nix { }) # xmrig
  ];
}
