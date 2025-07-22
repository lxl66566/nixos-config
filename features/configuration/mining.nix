{
  lib,
  pkgs,
  features,
  ...
}:

{
  boot.kernel.sysctl."vm.swappiness" = lib.mkIf (!features.desktop) (lib.mkForce 30);
  environment.systemPackages = with pkgs; [
    (callPackage ../../mynixpkgs/xmrig.nix { }) # xmrig
  ];
}
