{ description = "NixOS configuration";

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
            specialArgs = { inherit inputs; };
            modules = [
                ./host/laptop.nix
                home-manager.nixosModules.home-manager {
                    home-manager = {
                        useGlobalPkgs = true;
                        useUserPackages = true;
                        users.ren.imports = [
                            ./home/laptop.nix
                            inputs.sops-nix.homeManagerModule
                        ];
                        extraSpecialArgs = { inherit inputs; };
                        sharedModules = [ sops-nix.homeManagerModules.sops ];
                    };
                }
                sops-nix.nixosModules.sops
            ];
        };
    };
};
}
