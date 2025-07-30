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
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # daeuniverse = {
    #   url = "github:daeuniverse/flake.nix";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    nix-gaming = {
      url = "github:fufexan/nix-gaming";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # niri = {
    #   url = "github:sodiboo/niri-flake";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      plasma-manager,
      nix-gaming,
      nur,
      # niri,
      ...
    }@inputs:
    let
      lib = nixpkgs.lib;
      # default features
      #
      # desktop: for graphics displaying system
      # laptop: for laptop, which needs performance control and power management
      # server: for remote connection (openssh) and other setups like disko
      # mini: for device that has very little resources, often used for bootstrapping. cannot be used with `desktop`.
      # wsl: for nixos that on windows subsystem of linux
      # like_to_build: some packages are not so widely used, so the nix cache often misses and needs to build them.
      # impermanence: for bootstraping to root_on_tmpfs. If set to true, you are aware of the impermanence usage and risks.
      defaultFeatures = {
        gaming = false;
        desktop = false;
        laptop = false;
        programming = false;
        mining = false;
        server = {
          enable = false;
          type = "local"; # "local" server or "remote" vps
          domain = null; # domain of the remote server
          as_proxy = false; # use this server as a proxy node
        };
        mini = false;
        wsl = false;
        like_to_build = false;
        impermanence = false;
      };
      # a function to generate a system with specific features
      mkSystem =
        {
          system ? "x86_64-linux",
          userFeatures ? defaultFeatures,
          devicename ? "main",
          username ? "absx",
        }:
        let
          # merge default features with user features
          features = defaultFeatures // userFeatures;
        in
        lib.nixosSystem {
          inherit system;
          # specialArgs 会被传递给所有模块
          specialArgs = {
            inherit
              inputs
              features
              devicename
              username
              nur
              ;
          };
          modules = [
            inputs.impermanence.nixosModules.impermanence
            inputs.disko.nixosModules.disko
            # inputs.niri.nixosModules.niri
            { nix.settings.trusted-users = [ username ]; }

            # 基础配置和所有 feature 模块的定义
            ./configuration.nix
          ]
          ++ (lib.optional features.gaming ./features/configuration/gaming.nix)
          ++ (lib.optional features.desktop ./features/configuration/desktop.nix)
          ++ (lib.optional features.server.enable ./features/configuration/server.nix)
          ++ (lib.optional features.programming ./features/configuration/programming.nix)
          ++ (lib.optional features.laptop ./features/configuration/laptop.nix)
          ++ (lib.optional features.mining ./features/configuration/mining.nix)
          ++ (lib.optional features.wsl ./features/configuration/wsl.nix)
          # ++ (lib.optional (!features.mini) inputs.daeuniverse.nixosModules.dae) # use dae flake may need to compile dae from source, which is not acceptable for mini NixOS
          ++ [
            # 导入 home-manager 模块
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = {
                inherit
                  inputs
                  features
                  devicename
                  username
                  nur
                  ;
              };
              home-manager.backupFileExtension = "backup";
              home-manager.users.${username} = {
                imports = [
                  ./home.nix
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
        # region main
        "main" = mkSystem {
          devicename = "main";
          username = "absx";
          userFeatures = {
            gaming = true;
            desktop = true;
            laptop = false;
            programming = true;
            mining = true;
            mini = false;
            wsl = false;
            like_to_build = true;
            impermanence = true; # If you are installing new nixos, set this to false; after installation, you can set it to true and `sudo nixos-rebuild boot --flake .#main` (do not use switch!)
          };
        };
        # region wsl
        # https://github.com/nix-community/nixos-wsl
        # sudo cp -r . /etc/nixos
        # cd /etc/nixos
        # sudo nixos-rebuild switch --show-trace --flake .#wsl --impure --option substituters https://mirrors.ustc.edu.cn/nix-channels/store
        "wsl" = mkSystem {
          devicename = "wsl";
          username = "nixos";
          userFeatures = {
            programming = true;
            wsl = true;
          };
        };
        # region localserver
        "ls" = mkSystem {
          devicename = "localserver";
          username = "root";
          userFeatures = {
            mini = false;
            mining = true;
            like_to_build = true;
            server = {
              enable = true;
              type = "local";
              domain = null;
              as_proxy = false;
            };
          };
        };
        # region vps
        # for building vps-usable image, https://lantian.pub/article/modify-computer/nixos-low-ram-vps.lantian/
        # nix build .#image
        "vps" = mkSystem {
          devicename = "vps";
          username = "root";
          userFeatures = {
            wsl = false;
            mini = true;
            server = {
              enable = true;
              type = "remote";
              domain = null;
              as_proxy = true;
            };
          };
        };
      };

      packages.x86_64-linux = {
        image = self.nixosConfigurations.vps.config.system.build.diskoImages;
      };
    };
}
