{
  description = "NixOS configuration";
  nixConfig = {
    # substituers will be appended to the default substituters when fetching packages
    extra-substituters = [
      # "https://hyprland.cachix.org"
      # "https://nixpkgs-wayland.cachix.org"
      # "https://nix-gaming.cachix.org"
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
    };
    # catppuccin = {
    #   url = "github:catppuccin/nix";
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
    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    amber.url = "github:Ph0enixKM/Amber";
  };
  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      plasma-manager,
      # impermanence,
      nix-gaming,
      amber,
      # catppuccin,
      niri,
      ...
    }@inputs:
    {
      nixosConfigurations.absx = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules =
          [
            # inputs.impermanence.nixosModules.impermanence
            inputs.daeuniverse.nixosModules.dae
            inputs.niri.nixosModules.niri
            { nix.settings.trusted-users = [ "absx" ]; }
            ./configuration.nix
            # catppuccin.nixosModules.catppuccin
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.absx = {
                imports = [
                  ./home.nix
                  # anyrun.homeManagerModules.default
                  # catppuccin.homeModules.catppuccin
                ];
              };
              home-manager.extraSpecialArgs = inputs;
              home-manager.backupFileExtension = "backup";
            }
          ]
          ++ (with nix-gaming.nixosModules; [
            pipewireLowLatency
            platformOptimizations
          ]);
      };
    };
}
