{
  lib,
  pkgs,
  features,
  ...
}:

{
  boot.kernel.sysctl."vm.swappiness" = lib.mkIf (features.desktop == [ ]) (lib.mkForce 30);
  environment.systemPackages = with pkgs; [
    xmrig
  ];
  environment.shellAliases = {
    mine = "sudo nice -n 10 xmrig -c ~/xmrig.json";
  };
}
