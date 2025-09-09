# the type definition of my disk
{
  lib,
  config,
  ...
}:
let
  # 为了方便引用，创建一个变量 cfg
  cfg = config.userHardware;
in
{
  options.userHardware = {
    disk = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "The disk device UUID.";
    };
    boot_uuid = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "The boot partition UUID.";
    };
    main_uuid = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "The main partition UUID.";
    };
  };
  config = {
    assertions = [
      {
        assertion = cfg.disk != null || (cfg.boot_uuid != null && cfg.main_uuid != null);
        message = "必须设置 userHardware.disk，或者同时设置 userHardware.boot_uuid 和 userHardware.main_uuid。";
      }
    ];
    warnings = lib.optionals (cfg.boot_uuid == null || cfg.main_uuid == null) [
      "如果没有设置 userHardware.boot_uuid 和 userHardware.main_uuid，则可能会导致 NixOS 启动失败。"
    ];
  };
}
