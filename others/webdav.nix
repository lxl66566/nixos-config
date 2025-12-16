{
  pkgs,
  lib,
  features,
  ...
}:
let
  port = 4918;
  domain = features.server.domain;
in
{
  users.groups.webdav = { };
  users.users.webdav = {
    isSystemUser = true;
    createHome = true;
    home = "/home/webdav";
    shell = pkgs.shadow; # 禁止 SSH 登录
  };

  # nix-shell -p apacheHttpd --run "htpasswd -nb -B webdav <password>"
  # here uses my proxy_password
  environment.etc."htpasswd" = {
    text = ''
      webdav:$2y$05$opnN3ORGozLIVxkfPoZdBOBoYrW2IL4p.kNfKa40yUejgba5013l.
    '';
    mode = "0644";
  };

  services.webdav-server-rs = {
    enable = true;
    settings = {
      server.listen = [
        "0.0.0.0:${toString port}"
        "[::]:${toString port}"
      ];
      accounts = {
        auth-type = "htpasswd.default";
        acct-type = "unix";
      };
      htpasswd.default = {
        htpasswd = "/etc/htpasswd";
      };
      location = [
        # {
        #   route = [ "/public/*path" ];
        #   directory = "/srv/public";
        #   handler = "filesystem";
        #   methods = [ "webdav-ro" ];
        #   autoindex = true;
        #   auth = "false";
        # }
        {
          route = [ "/:user/*path" ];
          directory = "~";
          handler = "filesystem";
          methods = [ "webdav-rw" ];
          autoindex = true;
          auth = "true";
          setuid = true;
        }
      ];
    };
  };

  # serve webdav at /webdav on any domain
  services = {
    caddy =
      let
        caddyContent = ''
          handle /webdav/* {
            reverse_proxy localhost:${toString port}
          }
        '';
      in
      lib.mkMerge [
        {
          enable = true;
          virtualHosts."*" = {
            extraConfig = lib.mkBefore caddyContent;
          };
        }

        # 只有当 domain 存在且不为空时才应用
        (lib.mkIf (domain != null && domain != "") {
          virtualHosts."${domain}" = {
            extraConfig = lib.mkBefore caddyContent;
          };
        })
      ];
  };
}
