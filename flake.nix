{

  description = "NixOS configuration";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    # daeuniverse.url = "github:daeuniverse/flake.nix";
  };
  outputs =
    {
      self,
      nixpkgs,
      # home-manager,
      ...
    }@inputs:
    {
      nixosConfigurations.absx = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
          # inputs.daeuniverse.nixosModules.dae
          # inputs.daeuniverse.nixosModules.daed

          # home-manager.nixosModules.home-manager
          # {
          #   home-manager.useGlobalPkgs = true;
          #   home-manager.useUserPackages = true;
          #   home-manager.users.absx = import ./home.nix;
          # }
        ];
      };
    };
}
