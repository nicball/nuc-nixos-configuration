{
  inputs = {
    nicpkgs.url = "github:nicball/nicpkgs";
    nixpkgs.url = "github:NixOS/nixpkgs/dd9b079222d43e1943b6ebd802f04fd959dc8e61";
    instaepub.url = "github:nicball/instaepub";
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, nicpkgs, nix-index-database, instaepub, ... }: {
    nixosConfigurations.nixos-nuc = nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        nicpkgs.nixosModules.default
        nix-index-database.nixosModules.nix-index
        ({ ... }: { nixpkgs.overlays = [ (_: _: { instaepub = instaepub.packages.x86_64-linux.instaepub;  }) ]; })
      ];
    };
  };
}
