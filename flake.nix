{
  description = "NixOS configuration";
  nixConfig = {
    # substituers will be appended to the default substituters when fetching packages
    extra-substituters = [
      # "https://nixpkgs-wayland.cachix.org"
      "https://nix-gaming.cachix.org"
      "https://nix-community.cachix.org"
      "https://niri.cachix.org"
      "https://catppuccin.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
      "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
      "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
      "catppuccin.cachix.org-1:noG/4HkbhJb+lUAdKrph6LaozJvAeEEZj4N732IysmU="
    ];
    # accept-flake-config = false; # manually added the substituter config to avoid niri bootstrap
  };
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # nix-std.url = "github:chessai/nix-std";
    impermanence.url = "github:nix-community/impermanence";
    # flake-utils.url = "github:numtide/flake-utils";
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
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-stable.follows = "nixpkgs";
    };
    dgop = {
      url = "github:AvengeMedia/dgop";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dankMaterialShell = {
      url = "github:AvengeMedia/DankMaterialShell";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.dgop.follows = "dgop";
    };
    # quickshell = {
    #   url = "github:outfoxxed/quickshell";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
      # inputs.quickshell.follows = "quickshell";
    };
    catppuccin = {
      url = "github:catppuccin/nix";
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
      # networking default
      TPDomain = "852456.xyz";
      noProxy = "localhost,127.0.0.1,::1,.local,192.168.0.0/16,10.0.0.0/8,172.16.0.0/12";
      defaultNameServers = [
        "1.1.1.1"
        "8.8.8.8"
        "2606:4700:4700::1111"
        "2001:4860:4860::8888"
      ];
      # a function to generate a system with specific features
      mkSystem =
        {
          system ? "x86_64-linux",
          userFeatures ? defaultFeatures,
          devicename ? "main",
          username ? "absx",
          networking ? { },
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
              self
              inputs
              features
              devicename
              username
              useBtrfs
              noProxy
              ;
          };
          modules = [
            inputs.impermanence.nixosModules.impermanence
            inputs.disko.nixosModules.disko
            pkgs.nur.repos.lxl66566.nixosModules.system76-scheduler-niri
            { nix.settings.trusted-users = [ username ]; }

            # base configuration and all feature modules
            ./configuration.nix

            # types of features
            ./features/types.nix

            (
              { ... }:
              {
                networking = networking;
              }
            )

            "${self}/others/theme/catppuccin.nix"
          ]
          ++ (lib.optional features.gaming ./features/gaming.nix)
          ++ (lib.optional (features.desktop != [ ] && !features.wsl) ./features/desktop.nix)
          ++ (lib.optional features.server.enable ./features/server.nix)
          ++ (lib.optional features.laptop ./features/laptop.nix)
          ++ (lib.optional features.mini ./features/mini.nix)
          ++ (lib.optional features.mining ./features/mining.nix)
          ++ (lib.optional features.wsl ./features/wsl.nix)
          ++ (lib.optional features.programming ./features/programming.nix)
          ++ [
            # home-manager module
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { };
              home-manager.backupFileExtension = "backup";
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
        # sudo nixos-rebuild switch --show-trace --flake .#wsl --option substituters https://mirrors.ustc.edu.cn/nix-channels/store
        "wsl" = mkSystem {
          devicename = "wsl";
          username = "nixos";
          userFeatures = {
            desktop = [ "niri" ];
            programming = true;
            wsl = true;
            like_to_build = true;
            others = [ ./others/desktop ];
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
              ./others/steamauto
            ];
          };
        };
        # region vps
        # old method (currently not used): https://lantian.pub/article/modify-computer/nixos-low-ram-vps.lantian/ , nix build .#image
        #
        # now I use https://github.com/bin456789/reinstall :
        #
        # curl -O https://raw.githubusercontent.com/bin456789/reinstall/main/reinstall.sh || wget -O reinstall.sh $_
        # bash reinstall.sh nixos --ssh-key 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKhsZBFg1jO+wWYvOxtS+q4cuYXCEzCs+qHH6c1pPunX lxl66566@gmail.com' --ssh-key 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDzpOO88tLGqLQ6BeyWydGY6H4e0DesiNaVUiP6nhsKW lxl66566@gmail.com' --ssh-key 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA8MA5ciuFugeCNfPwI5yKIuqP4QQvPdWrHZDm9vSgel absx@absx'
        #
        # after installation, you can:
        #
        # (get the hardware config from remote /etc/nixos/hardware-configuration.nix to this repo: hardware/rfc.nix)
        # (get the network config from remote /etc/nixos/configuration.nix to this repo: see below)
        # then:
        # nixos-rebuild switch --flake .#rfc --target-host rfc                    # build on local, and copy all paths to target host
        # nixos-rebuild switch --flake .#rfc --target-host rfc --build-host rfc   # eval on local but build on remote
        # or
        # nh os switch . -H rfc --target-host rfc -- --impure
        #
        # only eval:
        # nix build .#nixosConfigurations.<hostname>.config.system.build.toplevel --dry-run
        "rfc" = mkSystem rec {
          devicename = "rfc";
          username = "root";
          userFeatures = {
            mini = true;
            server = {
              enable = true;
              type = "remote";
              domain = "${devicename}.${TPDomain}";
              as_proxy = true;
            };
          };
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
            nameservers = defaultNameServers;
          };
        };

        "dedi" = mkSystem rec {
          devicename = "dedi";
          username = "root";
          userFeatures = {
            mini = false;
            server = {
              enable = true;
              type = "remote";
              domain = "${devicename}.${TPDomain}";
              as_proxy = true;
            };
          };
        };
        "claw" = mkSystem rec {
          devicename = "claw";
          username = "root";
          userFeatures = {
            mini = false;
            server = {
              enable = true;
              type = "remote";
              domain = "${devicename}.${TPDomain}";
              as_proxy = true;
            };
          };
        };
        "acck" = mkSystem rec {
          devicename = "acck";
          username = "root";
          userFeatures = {
            mini = false;
            server = {
              enable = true;
              type = "remote";
              domain = "${devicename}.${TPDomain}";
              disk_name = "/dev/sda";
              as_proxy = true;
            };
          };
          networking = {
            usePredictableInterfaceNames = false;
            interfaces.eth0.ipv4.addresses = [
              {
                address = "156.231.140.190";
                prefixLength = 23;
              }
            ];
            defaultGateway = {
              address = "156.231.140.1";
              interface = "eth0";
            };
            # ipv6 disabled
            #
            # interfaces.eth0.ipv6.addresses = [
            #   {
            #     address = "2602:fa4f:b01:3629:70ef:e8be:a9b2:7593";
            #     prefixLength = 64;
            #   }
            # ];
            # defaultGateway6 = {
            #   address = "2602:fa4f:b01::1";
            #   interface = "eth0";
            # };
            nameservers = defaultNameServers;
          };
        };
      };

      packages.x86_64-linux = {
        image = self.nixosConfigurations.vps.config.system.build.diskoImages;
      };
    };
}
