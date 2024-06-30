{
  description = "NixOS configuration";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    nix-alien.url = "github:thiagokokada/nix-alien";
    impermanence.url = "github:nix-community/impermanence"; # not used
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    daeuniverse.url = "github:daeuniverse/flake.nix";
  };
  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      nix-alien,
      ...
    }@inputs:
    {
      nixosConfigurations.absx = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
          # inputs.daeuniverse.nixosModules.dae
          # inputs.daeuniverse.nixosModules.daed

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.absx = import ./home.nix;
            home-manager.extraSpecialArgs = inputs;
            home-manager.backupFileExtension = "bakcup";
          }
          (
            { self, system, ... }:
            {
              environment.systemPackages = with self.inputs.nix-alien.packages.${system}; [ nix-alien ];
              # Optional, needed for `nix-alien-ld`
              programs.nix-ld.enable = true;
            }
          )
        ];
      };
    };
}
