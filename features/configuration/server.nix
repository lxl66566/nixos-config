{
  lib,
  inputs,
  pkgs,
  devicename,
  features,
  config,
  ...
}:

{
  imports = lib.optionals (features.server.type == "remote") [
    ./server-remote.nix
    ../../others/network/easytier.nix
  ];

  swapDevices = lib.mkDefault [
    {
      device = "/nix/swapfile";
      size = 2 * 1024; # 2GB
    }
  ];

  networking = {
    enableIPv6 = lib.mkDefault false; # true; # trojan-go needs ipv6, ref https://github.com/p4gefau1t/trojan-go/issues/524
    firewall = {
      enable = false; # nftables conflict with firewall; fail2ban can not be used without a firewall/nftables
      # allow all ports
      allowedTCPPortRanges = [
        {
          from = 0;
          to = 65535;
        }
      ];
      allowedUDPPortRanges = [
        {
          from = 0;
          to = 65535;
        }
      ];
    };
    nameservers = [
      "8.8.8.8"
      "8.8.4.4"
      "1.1.1.1"
      "1.0.0.1"
      "223.5.5.5"
    ];
    usePredictableInterfaceNames = false;
    useDHCP = true;
  }
  // (features.server.networking or {
    # networkmanager = {
    #   enable = true;
    #   dhcp = "dhcpcd";
    # };
  }
  );

  systemd.network =
    features.server.network or {
      enable = false;
    };

  users = {
    mutableUsers = true;
    users.root = {
      # my "vps" password
      initialHashedPassword = "$6$CAF317uZ0TflvUR/$bc7f1k3ThJJb2VaIr7F2hu1JQIIzna/SUee7C5V4JiceyRJfBHfOPVfbN2hJQHkGUcdnsooucSgk9gsdE2KEu0";
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKhsZBFg1jO+wWYvOxtS+q4cuYXCEzCs+qHH6c1pPunX lxl66566@gmail.com" # windows ssh key
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA8MA5ciuFugeCNfPwI5yKIuqP4QQvPdWrHZDm9vSgel absx@absx" # nixos ssh key
      ];
    };
  };

  environment = {
    systemPackages =
      with pkgs;
      [
        dufs # simple file http server
      ]
      ++ (lib.optionals (features.server.type == "local") [
        pciutils
      ]);
  };

  services = {
    resolved.enable = false;
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
