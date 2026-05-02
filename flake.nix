{
  inputs = {
    nicpkgs.url = "github:nicball/nicpkgs";
    nixpkgs.url = "github:NixOS/nixpkgs/15f4ee454b1dce334612fa6843b3e05cf546efab";
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
