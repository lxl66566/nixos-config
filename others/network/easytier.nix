{
  self,
  lib,
  pkgs,
  devicename,
  ...
}:
let
  base = "852456.xyz";
  listenerPortTcp = 11010;
  listenerPortQuic = 1357; # small enough port number
  networkName = "lxl66566";

  # 内网服务器列表，这些服务器不会被添加到 peer
  internalServers = [
    "ls" # 10.0.0.1
  ];
  # 公网服务器列表，这些服务器将互相作为 peer
  publicServers = [
    "claw" # 10.0.0.2
    "rfc" # 10.0.0.3
    "dedi" # 10.0.0.4
  ];
  allServers = internalServers ++ publicServers;

  # peers 排除内网和自己
  peers = builtins.concatMap (elem: [
    "udp://${elem}.${base}:${toString listenerPortTcp}"
    "tcp://${elem}.${base}:${toString listenerPortTcp}"
    "quic://${elem}.${base}:${toString listenerPortQuic}"
  ]) (builtins.filter (server: server != devicename) publicServers);
  # IP 地址的分配逻辑现在基于 allServers，确保每个设备都有唯一的 IP
  index = (lib.lists.findFirstIndex (elem: elem == devicename) (-1) allServers) + 1;
  ipv4 = "10.0.0.${builtins.toString index}/28";
in
{
  services.easytier = {
    enable = true;
    allowSystemForward = true;
    instances."${devicename}" = {
      enable = true;
      settings = {
        hostname = devicename;
        network_name = networkName;
        network_secret = builtins.readFile "${self}/config/proxy_password";
        listeners = [
          "udp://0.0.0.0:${toString listenerPortTcp}"
          "tcp://0.0.0.0:${toString listenerPortTcp}"
          "quic://0.0.0.0:${toString listenerPortQuic}"
        ];
        inherit peers ipv4;
      };
      extraSettings = {
        port_forward = [
          # {
          #   bind_addr = "0.0.0.0:11111";
          #   dst_addr = "10.0.0.1:4396";
          #   proto = "tcp";
          # }
        ];
        flags = {
          # use quic, disable kcp. https://easytier.cn/guide/network/kcp-proxy.html
          enable_kcp_proxy = false;
          disable_kcp_input = true;
          enable_quic_proxy = true;
          disable_quic_input = false;

          default_protocol = "quic"; # use quic by default

          latency_first = true;
          compression = "zstd";
          accept_dns = true;
          private_mode = true;
          # https://easytier.cn/guide/network/host-public-server.html#关闭转发
          relay_network_whitelist = networkName;
          relay_all_peer_rpc = true;
        };
      };
    };
  };

  networking.nameservers = lib.mkBefore [ "100.100.100.101" ];

  # 重要服务保活！！
  systemd.timers."easytier-${devicename}" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      # 开机 30s 后先检查/启动一次
      OnBootSec = "30s";
      # 当服务进入 "Inactive" (停止) 状态后，计时 30s，然后再次启动它。
      OnUnitInactiveSec = "30s";
    };
  };
}
