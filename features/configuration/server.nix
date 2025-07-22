{
  lib,
  inputs,
  pkgs,
  ...
}:

{
  networking = {
    # assume you are using ipv4 server
    enableIPv6 = false;
  };
  services = {
    openssh = {
      enable = true;
      settings = {
        PermitRootLogin = lib.mkForce "yes";
        UseDns = true;
        PasswordAuthentication = true;
        X11Forwarding = lib.mkDefault true;
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
