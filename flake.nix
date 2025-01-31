{
    description = "NixOS configuration";

    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
        home-manager = {
            url = "github:nix-community/home-manager";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        sops-nix = {
            url = "github:mic92/sops-nix";
            inputs.nixpkgs.follows = "nixpkgs";
        };
    };

    outputs = inputs@{ nixpkgs, home-manager, sops-nix, ... }: {
        nixosConfigurations = {
            ren-laptop = nixpkgs.lib.nixosSystem {
                system = "x86_64-linux";
		specialArgs = {
                     inherit inputs;
		};
                modules = [
                    ./configuration.nix
                    home-manager.nixosModules.home-manager {
                        home-manager.useGlobalPkgs = true;
                        home-manager.useUserPackages = true;
                        home-manager.users.ren = import ./users/ren/home.nix;
			home-manager.extraSpecialArgs = { inherit inputs; };
                    }
                    sops-nix.nixosModules.sops
                ];
            };
        };
    };
}
