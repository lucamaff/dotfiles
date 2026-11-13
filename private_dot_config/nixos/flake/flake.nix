{
  description = "System flake";

  inputs = {
    # We use the unstable branch for bleeding-edge software
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-26.05";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };

  # The @inputs syntax captures all arguments into a single variable
  outputs = { self, nixpkgs, nixos-hardware }@inputs: {
    
    nixosConfigurations = {
      # "default" is the hostname. 
      # If your computer has a different hostname, change this key!
      surface = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        # specialArgs passes the 'inputs' variable down to your modules.
        # This allows your configuration.nix to access other flakes 
        # (like home-manager) in the future.
        specialArgs = { inherit inputs; };

        modules = [
          # We import your existing config
          ./hosts/surface/configuration.nix
          nixos-hardware.nixosModules.microsoft-surface-common
        ];
      };
    };
  };
}
