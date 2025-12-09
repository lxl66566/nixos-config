# defines some proxy services.
#
# inbound ports:
#
# hysteria: 65533
# trojan-go: 40000
# openppp2: 29777

{
  self,
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

  cert_base = "/var/lib/caddy/.local/share/caddy/certificates/acme-v02.api.letsencrypt.org-directory/${domain}/${domain}";
  caddy_cert_path_crt = cert_base + ".crt";
  caddy_cert_path_key = cert_base + ".key";

  # 硬链接后的证书路径
  linked_cert_dir = "/var/cert";
  linked_cert_path_crt = "${linked_cert_dir}/${domain}.crt";
  linked_cert_path_key = "${linked_cert_dir}/${domain}.key";
  cert-linker-script = ''
    mkdir -p ${linked_cert_dir}
    if [ ! -f "${caddy_cert_path_crt}" ] || [ ! -f "${caddy_cert_path_key}" ]; then
      echo "Caddy certificates not found yet, skipping link."
      exit 0
    fi
    echo "Linking Caddy certificates..."
    ln -f ${caddy_cert_path_crt} ${linked_cert_path_crt}
    ln -f ${caddy_cert_path_key} ${linked_cert_path_key}

    # 修改文件权限
    chmod 777 ${linked_cert_path_crt}
    chmod 777 ${linked_cert_path_key}

    echo "Certificates linked. Restarting dependent services..."
    # 尝试重启依赖服务以加载新证书。
    # 前面的 '-' 确保即使某个服务重启失败，整个脚本也不会失败。
    -${pkgs.systemd}/bin/systemctl try-restart trojan-go.service hysteria.service
  '';

  static_root = builtins.fetchTarball "https://github.com/lxl66566/thing-in-rings-with-ai/releases/download/v0.1.0/dist.tar.gz"; # a small static website to serve

  geoip = "${pkgs.v2ray-geoip}/share/v2ray/geoip.dat";
  geosite = "${pkgs.v2ray-domain-list-community}/share/v2ray/geosite.dat";
  password = pkgs.lib.fileContents "${self}/config/proxy_password";
  hysteria-config = pkgs.writeText "config.json" (
    builtins.toJSON {
      listen = ":5497";
      tls = {
        cert = linked_cert_path_crt;
        key = linked_cert_path_key;
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
      # 使用 quic 高位豁免；如果不使用 quic，则取消注释以下内容
      # obfs = {
      #   type = "salamander";
      #   salamander = {
      #     password = "make_hysteria_great_again";
      #   };
      # };
      ignoreClientBandwidth = true;
      quic = {
        maxIncomingStreams = 50000;
      };
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
        cert = linked_cert_path_crt;
        key = linked_cert_path_key;
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
    paths.caddy-cert-linker = {
      description = "Watch for Caddy certificate changes";
      wantedBy = [ "multi-user.target" ];
      pathConfig = {
        # 当证书文件被创建或修改时触发
        PathModified = caddy_cert_path_crt;
        Unit = "caddy-cert-linker.service";
      };
    };

    services = {
      caddy-cert-linker = {
        description = "Link Caddy certs and set permissions";
        # 一次性任务
        serviceConfig = {
          Type = "oneshot";
          StartLimitIntervalSec = 20;
        };
        script = cert-linker-script;
      };
      hysteria = {
        description = "Hysteria Server Service";
        after = [
          "network.target"
          "caddy.service"
          "caddy-cert-linker.service"
        ];
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
          "caddy.service"
          "caddy-cert-linker.service"
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
    rulesetFile = "${self}/config/nftables-proxy";
  };

  # security.acme = {
  #   acceptTerms = true;
  #   defaults = {
  #     email = "lxl66566@gmail.com";
  #     webroot = "/var/lib/acme/acme-challenge";
  #   };
  #   # directory = cert_base; # no longer has any effect; ACME Directory is now hardcoded to /var/lib/acme and its permissions are managed by systemd.
  #   certs."${domain}" = {
  #     postRun = ''
  #       chmod o+rx ${cert_base}/${domain}
  #       chmod o+r ${cert_path_crt}
  #       chmod o+r ${cert_path_key}
  #     '';
  #   };
  # };
  # services = {
  #   nginx = {
  #     enable = true;
  #     recommendedOptimisation = true;
  #     sslProtocols = "TLSv1 TLSv1.1 TLSv1.2 TLSv1.3";
  #     # 这是一个兼容性较好的加密套件列表，同时兼顾了安全性和对旧客户端的支持。
  #     sslCiphers = "ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-SHA256:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA384:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!MD5:!PSK:!SRP:!CAMELLIA";
  #     virtualHosts."${domain}" = {
  #       # 自动处理 ACME 的 http-01 验证。
  #       enableACME = true;
  #       forceSSL = false;
  #       locations."/" = {
  #         extraConfig = ''
  #           return 301 ${targetHost}$request_uri;
  #         '';
  #       };
  #     };
  #   };
  # };

  services = {
    caddy = {
      enable = true;
      configFile = pkgs.writeText "Caddyfile" ''
        ${domain}

        handle_path /thing-in-rings-with-ai/* {
          root * ${static_root}
          file_server
        }
        handle {
          root * ${static_root}
          file_server
        }
      '';
    };
  };

  users.users = {
    hysteria = {
      isSystemUser = true;
      group = "hysteria";
      extraGroups = [
        "caddy"
        "acme"
      ];
      home = "/var/lib/hysteria";
      createHome = true;
    };
    # nginx.extraGroups = [ "acme" ];
    trojan-go = {
      isSystemUser = true;
      group = "trojan-go";
      extraGroups = [
        "caddy"
        "acme"
      ];
    };
  };
  users.groups.hysteria = { };
  users.groups.trojan-go = { };
}
