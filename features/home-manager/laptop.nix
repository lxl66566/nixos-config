{
  lib,
  pkgs,
  ...
}:

{
  home.file = {
    "auto-cpufreq/auto-cpufreq.conf".source =
      config.lib.file.mkOutOfStoreSymlink ./config/auto-cpufreq.conf;
  };
  home.package = with pkgs; [
    lm_sensors
  ];
}
