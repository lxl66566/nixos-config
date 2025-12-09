{
  lib,
  inputs,
  pkgs,
  username,
  ...
}:

{
  hardware = {
    tuxedo-rs = {
      enable = true;
      tailor-gui.enable = true;
    };
  };

  # specialisation = {
  #   on-the-go.configuration = {
  #     system.nixos.tags = [ "on-the-go" ];
  #     hardware.nvidia = {
  #       prime.offload.enable = lib.mkForce true;
  #       prime.offload.enableOffloadCmd = lib.mkForce true;
  #       prime.sync.enable = lib.mkForce false;
  #       powerManagement.finegrained = lib.mkForce true;
  #     };
  #     powerManagement.cpuFreqGovernor = lib.mkForce "powersave";
  #     powerManagement.powertop.enable = lib.mkForce true;
  #   };
  # };

  boot.kernelModules = lib.mkAfter [
    "coretemp"
    # "ryzen_smu" # for ryzenadj
  ];
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
    xserver.libinput.enable = true;
  };

  environment = {
    etc."sysconfig/lm_sensors".text = ''
      HWMON_MODULES="coretemp"
    '';
    systemPackages = with pkgs; [
      # ryzenadj # AMD CPU Power limit, but "Only Ryzen Mobile Series are supported"
    ];
  };

  systemd.sleep.extraConfig = ''
    AllowSuspend=yes
    AllowHibernation=yes
    AllowHybridSleep=yes
    AllowSuspendThenHibernate=no
    HibernateDelaySec=1h
  '';

  home-manager.users.${username} = {
    home.file = {
      "auto-cpufreq/auto-cpufreq.conf".source = ./config/auto-cpufreq.conf;
    };
    home.package = with pkgs; [
      lm_sensors
    ];
  };
}
