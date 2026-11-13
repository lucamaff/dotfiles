{
  description = "System flake";

  inputs = {
    # We use the unstable branch for bleeding-edge software
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-26.05";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  # The @inputs syntax captures all arguments into a single variable
  outputs = { self,
    nixpkgs,
    nixos-hardware,
    home-manager,
    plasma-manager,
    ...
    }@inputs: {
    
    nixosConfigurations = {
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

      steam = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        # specialArgs passes the 'inputs' variable down to your modules.
        # This allows your configuration.nix to access other flakes 
        # (like home-manager) in the future.
        specialArgs = { inherit inputs; };

        modules = [
          # We import your existing config
          ./hosts/steam/configuration.nix
          home-manager.nixosModules.default
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              sharedModules = [ plasma-manager.homeModules.plasma-manager ];

              users.luca = ./hosts/steam/home.nix; # replace <USERNAME> with your actual username
            };
          }
        ];
      };
    };
  };
}
