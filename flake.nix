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
    # nix-std.url = "github:chessai/nix-std";
    impermanence.url = "github:nix-community/impermanence";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
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
    # use nixpkgs' instead
    # niri = {
    #   url = "github:sodiboo/niri-flake";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      nix-gaming,
      nur,
      # niri,
      ...
    }@inputs:
    let
      lib = nixpkgs.lib;
      # default features. you can find the meaning of them in ./features/types.nix
      defaultFeatures = {
        gaming = false;
        desktop = [ ];
        laptop = false;
        programming = false;
        mining = false;
        server = {
          enable = false;
          type = "local"; # "local" server or "remote" vps
          domain = null; # domain of the remote server
          as_proxy = false; # use this server as a proxy node
          network = { };
          disko = false;
        };
        mini = false;
        wsl = false;
        like_to_build = false;
        impermanence = false;
        others = [ ];
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
          features = lib.recursiveUpdate defaultFeatures userFeatures;
          pkgs = import nixpkgs {
            inherit system;
            overlays = [
              nur.overlays.default
              (import ./overlays)
              (import ./overlays/desktop.nix)
            ];
            config = import ./config/nix-config.nix;
          };
          useBtrfs =
            !features.mini && !(features.server.enable && features.server.type == "remote") && !features.wsl;
        in
        lib.nixosSystem {
          inherit pkgs;
          # specialArgs will be passed to all modules
          specialArgs = {
            inherit
              inputs
              features
              devicename
              username
              useBtrfs
              ;
          };
          modules = [
            inputs.impermanence.nixosModules.impermanence
            inputs.disko.nixosModules.disko
            # inputs.niri.nixosModules.niri
            { nix.settings.trusted-users = [ username ]; }

            # base configuration and all feature modules
            ./configuration.nix

            # types of features
            ./features/types.nix
          ]
          ++ (lib.optional features.gaming ./features/configuration/gaming.nix)
          ++ (lib.optional (features.desktop != [ ] && !features.wsl) ./features/configuration/desktop.nix)
          ++ (lib.optional (builtins.elem "niri" features.desktop) ./others/niri)
          ++ (lib.optional (builtins.elem "plasma" features.desktop) ./others/plasma)
          ++ (lib.optional features.server.enable ./features/configuration/server.nix)
          ++ (lib.optional features.laptop ./features/configuration/laptop.nix)
          ++ (lib.optional features.mining ./features/configuration/mining.nix)
          ++ (lib.optional features.wsl ./features/configuration/wsl.nix)
          # ++ (lib.optional (!features.mini) inputs.daeuniverse.nixosModules.dae) # use dae flake may need to compile dae from source, which is not acceptable for mini NixOS
          ++ [
            # home-manager module
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
                  useBtrfs
                  ;
              };
              home-manager.backupFileExtension = "backup";
              home-manager.users.${username} = {
                imports = [
                  ./home.nix
                ]
                ++ (lib.optional features.gaming ./features/home-manager/gaming.nix)
                ++ (lib.optional (features.desktop != [ ] && !features.wsl) ./features/home-manager/desktop.nix)
                ++ (lib.optional (builtins.elem "niri" features.desktop) ./others/niri/home.nix)
                ++ (lib.optional (builtins.elem "plasma" features.desktop) ./others/plasma/home.nix)
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
            desktop = [
              "plasma"
              "niri"
            ];
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
            desktop = [ "niri" ];
            programming = true;
            wsl = true;
          };
        };
        # region localserver
        "ls" = mkSystem {
          devicename = "ls";
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
            others = [
              ./others/network/cftunnel.nix
              ./others/containers/reader.nix
            ];
          };
        };
        # region vps
        # old method (currently not used): https://lantian.pub/article/modify-computer/nixos-low-ram-vps.lantian/ , nix build .#image
        #
        # now I use https://github.com/bin456789/reinstall :
        #
        # curl -O https://raw.githubusercontent.com/bin456789/reinstall/main/reinstall.sh || wget -O reinstall.sh $_
        # bash reinstall.sh nixos --ssh-key ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKhsZBFg1jO+wWYvOxtS+q4cuYXCEzCs+qHH6c1pPunX lxl66566@gmail.com
        #
        # after installation, you can:
        #
        # (get the hardware config from remote /etc/nixos/hardware-configuration.nix to this repo: hardware/rfc.nix)
        # (get the network config from remote /etc/nixos/configuration.nix to this repo: see below)
        # nixos-rebuild boot --flake .#rfc --target-host rfc
        # or
        # nh os switch . -H rfc --target-host rfc -- --impure
        "rfc" = mkSystem {
          devicename = "rfc";
          username = "root";
          userFeatures = {
            mini = false;
            server = {
              enable = true;
              type = "remote";
              domain = "rfc.852456.xyz";
              as_proxy = true;
              networking = {
                interfaces.eth0.ipv4.addresses = [
                  {
                    address = "198.176.52.113";
                    prefixLength = 24;
                  }
                ];
                defaultGateway = {
                  address = "198.176.52.1";
                  interface = "eth0";
                };
                nameservers = [
                  "1.1.1.1"
                  "8.8.8.8"
                  "2606:4700:4700::1111"
                  "2001:4860:4860::8888"
                ];
              };
            };
          };
        };

        "dedi" = mkSystem {
          devicename = "dedi";
          username = "root";
          userFeatures = {
            mini = false;
            server = {
              enable = true;
              type = "remote";
              domain = "dedi.852456.xyz";
              as_proxy = true;
            };
          };
        };
        "claw" = mkSystem {
          devicename = "claw";
          username = "root";
          userFeatures = {
            mini = false;
            server = {
              enable = true;
              type = "remote";
              domain = "claw.852456.xyz";
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
