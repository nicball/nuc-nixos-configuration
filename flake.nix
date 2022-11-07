{
  inputs.emacs-overlay.url = "github:nix-community/emacs-overlay";
  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations.nicball-nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ ./configuration.nix ];
      specialArgs = inputs;
    };
  };
}
