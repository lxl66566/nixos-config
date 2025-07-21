{ lib, ... }:

{
  options.features = {
    desktop = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable graphics desktop features.";
    };

    gaming = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable gaming-related packages and settings.";
    };

    laptop = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable laptop-related packages and settings.";
    };

    programming = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable programming packages and settings.";
    };

    mining = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable xmrig and mining settings.";
    };
  };
}
