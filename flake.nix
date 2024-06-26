{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    # daeuniverse.url = "github:daeuniverse/flake.nix";
  };
  outputs = { self, nixpkgs, ... } @ inputs: {
    nixosConfigurations.absx = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ 
	./configuration.nix
	# inputs.daeuniverse.nixosModules.dae
	# inputs.daeuniverse.nixosModules.daed
      ];
    };
  };
}
