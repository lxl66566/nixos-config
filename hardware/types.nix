# the type definition of my disk
{
  lib,
  config,
  userHardware,
  ...
}:
{
  options.userHardware = {
    disk = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      description = "The disk device UUID.";
    };
    boot_uuid = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      description = "The boot partition UUID.";
    };
    main_uuid = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      description = "The main partition UUID.";
    };
  };
  config.userHardware = userHardware;
}
