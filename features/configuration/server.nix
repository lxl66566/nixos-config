{
  lib,
  inputs,
  pkgs,
  features,
  config,
  ...
}:

{
  imports = [
    ./server-remote.nix
  ];

  networking = {
    # assume you are using ipv4 server
    enableIPv6 = false;
    firewall.enable = true; # fail2ban can not be used without a firewall
  };

  users = {
    users.root = {
      # my "vps" password
      hashedPassword = "$6$m6Skk6dB0hu.eU4Y$oVCENpvE/wXpm9m4fw25oZrDG5E/Ovipr3hbaadibYHJ8.H4TzO6WRb1PBqGp2z.lATK3WorX42m/DAr4ruzh1";
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKhsZBFg1jO+wWYvOxtS+q4cuYXCEzCs+qHH6c1pPunX lxl66566@gmail.com" # windows ssh key
      ];
    };
  };

  services = {
    openssh = {
      enable = lib.mkForce true;
      settings = {
        PermitRootLogin = lib.mkForce "yes";
        UseDns = true;
        PasswordAuthentication = true;
        X11Forwarding = !features.mini;
        LogLevel = lib.mkDefault "VERBOSE";
      };
      hostKeys = [
        {
          bits = 4096;
          path = "/etc/ssh/ssh_host_rsa_key";
          type = "rsa";
        }
        {
          path = "/etc/ssh/ssh_host_ed25519_key";
          type = "ed25519";
        }
      ];
    };

    fail2ban = {
      enable = true;
      ignoreIP = [
        "10.0.0.0/8"
        "172.16.0.0/12"
        "192.168.0.0/24"
      ];
      maxretry = 10;
      bantime = "10min";
    };
  };
}
