{
  description = "NixOS configuration";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # impermanence.url = "github:nix-community/impermanence"; # not used
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    daeuniverse.url = "github:daeuniverse/flake.nix";
    catppuccin.url = "github:catppuccin/nix";
  };
  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      catppuccin,
      ...
    }@inputs:
    {
      nixosConfigurations.absx = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.absx = import ./home.nix;
            home-manager.extraSpecialArgs = inputs;
            home-manager.backupFileExtension = "bakcup";
          }
          catppuccin.nixosModules.catppuccin
        ];
      };
    };
}
