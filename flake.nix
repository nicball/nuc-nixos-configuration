{
  outputs = { self, nixpkgs }: {
    nixosConfigurations.nicball-nixos-nuc6i5syh = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ ./configuration.nix ];
    };
  };
}
