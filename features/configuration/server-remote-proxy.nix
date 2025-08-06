{
  lib,
  inputs,
  pkgs,
  features,
  config,
  ...
}:

let
  cert_base = "/var/lib/caddy/.local/share/caddy/certificates/acme-v02.api.letsencrypt.org-directory/${features.server.domain}/${features.server.domain}";
  cert_path_crt = cert_base + ".crt";
  cert_path_key = cert_base + ".key";
  geoip = "${pkgs.v2ray-geoip}/share/v2ray/geoip.dat";
  geosite = "${pkgs.v2ray-domain-list-community}/share/v2ray/geosite.dat";
  password = pkgs.lib.fileContents ../../config/proxy_password;
  hysteria-config = pkgs.writeText "config.json" (
    builtins.toJSON {
      listen = ":30000";
      tls = {
        cert = cert_path_crt;
        key = cert_path_key;
      };
      auth = {
        type = "password";
        password = password;
      };
      masquerade = {
        type = "proxy";
        proxy = {
          url = "https://absx.pages.dev";
          rewriteHost = true;
        };
      };
      obfs = {
        type = "salamander";
        salamander = {
          password = "make_hysteria_great_again";
        };
      };
      ignoreClientBandwidth = true;
    }
  );
  # nixpkgs does not have trojan!
  trojan-go-config = pkgs.writeText "config.json" (
    builtins.toJSON {
      run_type = "server";
      local_addr = "0.0.0.0";
      local_port = 40000;
      remote_addr = "127.0.0.1";
      remote_port = 80;
      password = [ password ];
      ssl = {
        cert = cert_path_crt;
        key = cert_path_key;
        fallback_port = 80;
        sni = features.server.domain;
      };
      mux = {
        enabled = true;
        concurrency = 3;
        idle_timeout = 10;
      };
      router = {
        enabled = true;
        bypass = [
          "geoip:cn"
          "geoip:private"
          "geosite:cn"
          "geosite:private"
        ];
        block = [ "geosite:category-ads" ];
        proxy = [ "geosite:geolocation-!cn" ];
        default_policy = "proxy";
        geoip = geoip;
        geosite = geosite;
      };
    }
  );
  openppp2-config = pkgs.writeText "config.json" (
    builtins.toJSON {
      concurrent = 1;
      key = {
        kf = 154543927;
        kx = 128;
        kl = 10;
        kh = 12;
        protocol = "aes-128-cfb";
        protocol-key = "N6HMzdUs7IUnYHwq";
        transport = "aes-256-cfb";
        transport-key = "HWFweXu2g5RVMEpy";
        masked = false;
        plaintext = false;
        delta-encode = false;
        shuffle-data = false;
      };
      ip = {
        public = "::";
        interface = "::";
      };
      tcp = {
        inactive = {
          timeout = 300;
        };
        connect = {
          timeout = 5;
        };
        listen = {
          port = 29777;
        };
        turbo = true;
        backlog = 511;
        fast-open = true;
      };
      udp = {
        inactive = {
          timeout = 72;
        };
        dns = {
          timeout = 4;
          redirect = "0.0.0.0";
        };
        listen = {
          port = 29777;
        };
      };
      server = {
        log = "/dev/null";
        node = 1;
      };
      client = {
        guid = "{F4569208-BB45-4DEB-B115-0FEA1D91B85B}";
        server = "ppp://192.168.0.24:20000/";
        bandwidth = 10000;
        reconnections = {
          timeout = 5;
        };
        paper-airplane = {
          tcp = true;
        };
        http-proxy = {
          bind = "192.168.0.24";
          port = 8080;
        };
      };
    }
  );
  restart_policy = {
    Restart = "on-failure";
    RestartSec = "20s";
    StartLimitBurst = 30000; # 服务允许尝试启动的总次数为 30000 次
    StartLimitIntervalSec = 0; # 设置为 0 以禁用基于时间的速率限制
  };
in
{
  systemd = {
    services = {
      hysteria = {
        description = "Hysteria Server Service";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.hysteria}/bin/hysteria server --config ${hysteria-config}";
          WorkingDirectory = "/var/lib/hysteria";
          User = "hysteria";
          Group = "hysteria";
          CapabilityBoundingSet = "CAP_NET_ADMIN CAP_NET_BIND_SERVICE CAP_NET_RAW";
          AmbientCapabilities = "CAP_NET_ADMIN CAP_NET_BIND_SERVICE CAP_NET_RAW";
          NoNewPrivileges = true;
        }
        // restart_policy;
        environment = {
          HYSTERIA_LOG_LEVEL = "info";
        };
      };
      trojan-go = {
        description = "Proxy mechanism to bypass GFW";
        documentation = [ "https://p4gefau1t.github.io/trojan-go/" ];
        after = [
          "network.target"
          "nss-lookup.target"
        ];

        serviceConfig = {
          DynamicUser = true;
          CapabilityBoundingSet = [
            "CAP_NET_ADMIN"
            "CAP_NET_BIND_SERVICE"
          ];
          AmbientCapabilities = [
            "CAP_NET_ADMIN"
            "CAP_NET_BIND_SERVICE"
          ];
          NoNewPrivileges = true;
          ExecStart = "${pkgs.trojan-go}/bin/trojan-go -config ${trojan-go-config}";
          LimitNOFILE = "infinity";
        }
        // restart_policy;

        wantedBy = [ "multi-user.target" ];
      };
      openppp2 = {
        description = "openppp2 tui server";
        after = [
          "network.target"
          "nss-lookup.target"
        ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          ExecStart = "${pkgs.nur.repos.lxl66566.openppp2}/bin/ppp --mode=server --config=${openppp2-config}";
          StandardOutput = "null";
          StandardError = "journal";
        }
        // restart_policy;
      };
    };
  };

  services = {
    caddy = {
      enable = true;
      configFile = pkgs.writeText "Caddyfile" ''
        ${features.server.domain}
        reverse_proxy caddyserver.com
      '';
    };
  };

  users.users.hysteria = {
    isSystemUser = true;
    group = "hysteria";
    home = "/var/lib/hysteria";
    createHome = true;
  };
  users.groups.hysteria = { };
}
