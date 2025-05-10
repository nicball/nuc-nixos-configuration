{
  inputs = {
    nicpkgs.url = "github:nicball/nicpkgs";
    nixpkgs.url = "github:NixOS/nixpkgs/f02fddb8acef29a8b32f10a335d44828d7825b78";
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
