{
  lib,
  pkgs,
  devicename,
  ...
}:
let
  base = "852456.xyz";

  # 公网服务器列表，这些服务器将互相作为 peer
  publicServers = [
    "claw" # 10.200.1.1
    "rfc" # 10.200.2.1
    "dedi" # 10.200.3.1
  ];

  # 新增的内网服务器列表，这些服务器不会被添加到 peer
  internalServers = [
    # "ls" # 10.200.4.1
  ];
  allServers = publicServers ++ internalServers;

  peers = builtins.map (elem: "udp://${elem}.${base}:11010") (
    builtins.filter (server: server != devicename) publicServers
  );
  # IP 地址的分配逻辑现在基于 allServers，确保每个设备都有唯一的 IP
  index = (lib.lists.findFirstIndex (elem: elem == devicename) (-1) allServers) + 1;
  ipv4 = "10.200.${builtins.toString index}.1/24";
in
{
  services.easytier = {
    enable = true;
    allowSystemForward = true;
    instances.lxl66566 = {
      enable = true;
      settings = {
        hostname = devicename;
        network_name = "lxl66566";
        network_secret = builtins.readFile ../../config/proxy_password;
        inherit peers ipv4;
      };
      extraSettings = {
        port_forward = [
          # {
          #   bind_addr = "0.0.0.0:11111";
          #   dst_addr = "115.115.115.115:65535";
          #   proto = "tcp";
          # }
        ];
        flags = {
          enable_kcp_proxy = true;
          enable_quic_proxy = true;
          latency_first = true;
          compression = "zstd";
          accept_dns = true;
          private-mode = true;
          # https://easytier.cn/guide/network/host-public-server.html#关闭转发
          # relay_network_whitelist = "";
          # relay_all_peer_rpc = true;
        };
      };
    };
  };

  networking.nameservers = lib.mkBefore [ "100.100.100.101" ];
}
