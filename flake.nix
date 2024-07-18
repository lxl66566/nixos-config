{
  description = "NixOS configuration";
  nixConfig = {
    # substituers will be appended to the default substituters when fetching packages
    extra-substituters = [
      # "https://anyrun.cachix.org"
      # "https://hyprland.cachix.org"
      # "https://nixpkgs-wayland.cachix.org"
      "https://nix-gaming.cachix.org"
      "https://daeuniverse.cachix.org"
    ];
    extra-trusted-public-keys = [
      # "anyrun.cachix.org-1:pqBobmOjI7nKlsUMV25u9QHa9btJK65/C8vnO3p346s="
      # "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      # "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
      "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
      "daeuniverse.cachix.org-1:8hRIzkQmAKxeuYY3c/W1I7QbZimYphiPX/E7epYNTeM="
    ];
  };
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    impermanence.url = "github:nix-community/impermanence";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    daeuniverse = {
      url = "github:daeuniverse/flake.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    catppuccin = {
      url = "github:catppuccin/nix";
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
    amber.url = "github:Ph0enixKM/Amber";
  };
  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      catppuccin,
      plasma-manager,
      impermanence,
      nix-gaming,
      amber,
      ...
    }@inputs:
    {
      nixosConfigurations.absx = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules =
          [
            inputs.impermanence.nixosModules.impermanence
            # inputs.daeuniverse.nixosModules.dae
            ./configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.absx = {
                imports = [ ./home.nix ];
              };
              home-manager.extraSpecialArgs = inputs;
              home-manager.backupFileExtension = "backup";
            }
            catppuccin.nixosModules.catppuccin
          ]
          ++ (with nix-gaming.nixosModules; [
            pipewireLowLatency
            platformOptimizations
          ]);
      };
    };
}
