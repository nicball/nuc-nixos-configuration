{
  outputs = { self, nixpkgs }: {
    nixosConfigurations.nicball-nixos-um560 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ ./configuration.nix ];
    };
  };
}
