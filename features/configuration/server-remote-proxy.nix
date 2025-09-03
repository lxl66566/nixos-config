{
  lib,
  inputs,
  pkgs,
  features,
  config,
  ...
}:

let
  domain = features.server.domain;
  targetHost = "https://absx.pages.dev"; # for redirecting
  cert_base = "/var/lib/acme";
  cert_path_crt = "${cert_base}/${domain}/cert.pem";
  cert_path_key = "${cert_base}/${domain}/key.pem";
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
          url = targetHost;
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
        sni = domain;
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
          Group = "acme";
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

  # nftables：高位 quic 豁免
  networking.nftables = {
    enable = true;
    rulesetFile = ../../config/nftables-proxy;
  };

  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "lxl66566@gmail.com";
      webroot = "/var/lib/acme/acme-challenge";
    };
    # directory = cert_base; # no longer has any effect; ACME Directory is now hardcoded to /var/lib/acme and its permissions are managed by systemd.
    certs."${domain}" = {
      postRun = ''
        chmod o+rx ${cert_base}/${domain}
        chmod o+r ${cert_path_crt}
        chmod o+r ${cert_path_key}
      '';
    };
  };

  services = {
    nginx = {
      enable = true;
      recommendedOptimisation = true;
      sslProtocols = "TLSv1 TLSv1.1 TLSv1.2 TLSv1.3";
      # 这是一个兼容性较好的加密套件列表，同时兼顾了安全性和对旧客户端的支持。
      # 它优先使用现代的 ECDHE 和 AES-GCM 算法，同时也包含了旧协议可能需要的算法。
      sslCiphers = "ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-SHA256:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA384:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!MD5:!PSK:!SRP:!CAMELLIA";
      virtualHosts."${domain}" = {
        # 自动处理 ACME 的 http-01 验证。
        enableACME = true;
        forceSSL = false;
        locations."/" = {
          extraConfig = ''
            return 301 ${targetHost}$request_uri;
          '';
        };
      };
    };
  };

  users.users = {
    hysteria = {
      isSystemUser = true;
      group = "hysteria";
      extraGroups = [ "acme" ];
      home = "/var/lib/hysteria";
      createHome = true;
    };
    nginx.extraGroups = [ "acme" ];
  };
  users.groups.hysteria = { };
}
