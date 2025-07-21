{
  lib,
  inputs,
  ...
}:

{
  hardware = {
    tuxedo-rs = {
      enable = true;
      tailor-gui.enable = true;
    };
  };
  powerManagement.cpuFreqGovernor = "ondemand";
  services = {
    tlp = {
      enable = false; # auto-cpufreq
      settings = {
        USB_AUTOSUSPEND = 0;
        RUNTIME_PM_ON_AC = "auto";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
        PLATFORM_PROFILE_ON_BAT = "low-power";
        CPU_BOOST_ON_BAT = 0;
        CPU_HWP_DYN_BOOST_ON_BAT = 0;
        CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
        PLATFORM_PROFILE_ON_AC = "performance";
      };
    };
    auto-cpufreq = {
      enable = false; # tlp
    };
    power-profiles-daemon.enable = false;
  };

  environment = {
    etc."sysconfig/lm_sensors".text = ''
      HWMON_MODULES="coretemp"
    '';
  };

  systemd.sleep.extraConfig = ''
    AllowSuspend=yes
    AllowHibernation=yes
    AllowHybridSleep=yes
    AllowSuspendThenHibernate=no
    HibernateDelaySec=1h
  '';
}
