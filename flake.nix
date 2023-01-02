{
  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations.nicball-nuc-nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ ./configuration.nix ];
    };
  };
}
