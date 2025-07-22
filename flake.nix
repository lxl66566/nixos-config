{
  description = "NixOS configuration";
  nixConfig = {
    # substituers will be appended to the default substituters when fetching packages
    extra-substituters = [
      # "https://hyprland.cachix.org"
      # "https://nixpkgs-wayland.cachix.org"
      "https://nix-gaming.cachix.org"
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
      "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
    ];
  };
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    impermanence.url = "github:nix-community/impermanence";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    daeuniverse = {
      url = "github:daeuniverse/flake.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    nix-gaming = {
      url = "github:fufexan/nix-gaming";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      plasma-manager,
      # impermanence,
      nix-gaming,
      niri,
      ...
    }@inputs:
    let
      # 函数，用于生成一个带特定 features 的系统
      lib = nixpkgs.lib;
      mkSystem =
        {
          system ? "x86_64-linux",
          features ? { },
          devicename ? "main",
        }:
        lib.nixosSystem {
          inherit system;
          # specialArgs 会被传递给所有模块
          specialArgs = { inherit inputs features devicename; };
          modules =
            [
              # inputs.impermanence.nixosModules.impermanence
              inputs.daeuniverse.nixosModules.dae
              # inputs.niri.nixosModules.niri
              { nix.settings.trusted-users = [ "absx" ]; }

              # 基础配置和所有 feature 模块的定义
              ./configuration.nix
            ]
            ++ (lib.optional features.gaming ./features/configuration/gaming.nix)
            ++ (lib.optional features.desktop ./features/configuration/desktop.nix)
            ++ (lib.optional features.server ./features/configuration/server.nix)
            ++ (lib.optional features.laptop ./features/configuration/laptop.nix)
            ++ (lib.optional features.mining ./features/configuration/mining.nix)
            ++ [
              # 导入 home-manager 模块
              home-manager.nixosModules.home-manager
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.extraSpecialArgs = { inherit inputs features devicename; };
                home-manager.backupFileExtension = "backup";
                home-manager.users.absx = {
                  imports =
                    [
                      ./home.nix # 基础 home 配置
                    ]
                    ++ (lib.optional features.gaming ./features/home-manager/gaming.nix)
                    ++ (lib.optional features.desktop ./features/home-manager/desktop.nix)
                    ++ (lib.optional features.laptop ./features/home-manager/laptop.nix)
                    ++ (lib.optional features.programming ./features/home-manager/programming.nix);
                };
              }
            ];
        };
    in
    {
      nixosConfigurations = {
        "main" = mkSystem {
          devicename = "main";

          # desktop: for graphics displaying system
          # laptop: for laptop, which needs performance control and power management
          # server: for remote connection
          # mini: for device that has very little resources. cannot be used with `desktop`.
          features = {
            gaming = true;
            desktop = true;
            laptop = false;
            programming = true;
            mining = true;
            server = false;
            mini = false;
          };
        };
      };
    };
}
