{
  self,
  config,
  pkgs,
  ...
}:
let
  password = pkgs.lib.fileContents "${self}/config/proxy_password";
in
{
  virtualisation.podman.enable = true;

  # 我们使用 /var/lib/reader 而不是 /home/reader，这是 NixOS 中存放服务数据的标准位置。
  # 系统将自动管理这些目录的创建。
  systemd.tmpfiles.rules = [
    "d /var/lib/reader/storage 0755 root root -"
    "d /var/lib/reader/logs 0755 root root -"
  ];

  # NixOS 会自动为此容器创建一个 systemd 服务，并默认设置为开机自启。
  virtualisation.oci-containers.containers.reader = {
    image = "hectorqin/reader";
    # 将主机的 4396 端口映射到容器的 8080 端口。
    ports = [ "4396:8080" ];

    # 将主机上创建的目录挂载到容器内部，用于持久化保存数据和日志。
    volumes = [
      "/var/lib/reader/storage:/storage"
      "/var/lib/reader/logs:/logs"
    ];

    # 设置容器的环境变量，用于配置 Reader 应用。
    environment = {
      SPRING_PROFILES_ACTIVE = "prod";
      READER_APP_USERLIMIT = "10";
      READER_APP_USERBOOKLIMIT = "2000";
      READER_APP_CACHECHAPTERCONTENT = "true";

      READER_APP_SECURE = "true";
      # 管理员密码
      READER_APP_SECUREKEY = password;
      # 注册邀请码
      READER_APP_INVITECODE = "absx";
    };
    # 在 NixOS 中，容器的默认重启策略就是 "always"，因此无需显式设置。
  };
}
