{
  inputs = {
    nicpkgs.url = "github:nicball/nicpkgs";
    nixpkgs.url = "github:NixOS/nixpkgs/4faa5f5321320e49a78ae7848582f684d64783e9";
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, nicpkgs, nix-index-database, ... }: {
    nixosConfigurations.nixos-nuc = nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        nicpkgs.nixosModules.default
        nix-index-database.nixosModules.nix-index
      ];
    };
  };
}
