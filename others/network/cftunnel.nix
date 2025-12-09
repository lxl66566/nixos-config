# to create cf tunnel:
#
# nix-shell -p cloudflared
# cloudflared tunnel login
# cloudflared tunnel create <tunnel name>
#
# and copy the json file to nix store.
{
  self,
  pkgs,
  lib,
  username,
  ...
}:
{
  services.cloudflared = {
    enable = true;
    tunnels = {
      # 隧道 UUID
      "a0290f42-d3ce-4ef5-a209-3ce3b9bf5d4a" = {
        default = "http_status:404";
        credentialsFile = "${self}/config/cloudflare/a0290f42-d3ce-4ef5-a209-3ce3b9bf5d4a.json";

        # 定义流量入口规则
        ingress = {
          "reader.852456.xyz" = "http://localhost:4396";
        };
      };
    };
  };
}
