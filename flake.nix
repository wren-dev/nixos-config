# vim vim: set ts=4 sw=4 et fdm=marker :
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
    disko = {
        url = "github:nix-community/disko";
        inputs.nixpkgs.follows = "nixpkgs";
    };
    lix = {
        url = "https://git.lix.systems/lix-project/nixos-module/archive/2.92.0.tar.gz";
        inputs.nixpkgs.follows = "nixpkgs";
    };
};

outputs = inputs@{ nixpkgs, home-manager, sops-nix, disko, lix, ... }: let
    vars = import ./modules/vars.nix;
in {
    nixosConfigurations = {
        ${vars.hostNames.laptop} = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            specialArgs = { inherit inputs; };
            modules = [
                ./modules/laptop/config.nix
                home-manager.nixosModules.home-manager {
                    home-manager = {
                        useGlobalPkgs = true;
                        useUserPackages = true;
                        users.${vars.userName}.imports = [
                            ./modules/laptop/home.nix
                            inputs.sops-nix.homeManagerModule
                        ];
                        extraSpecialArgs = { inherit inputs; };
                        sharedModules = [sops-nix.homeManagerModules.sops ];
                    };
                }
                sops-nix.nixosModules.sops
                disko.nixosModules.disko
                lix.nixosModules.default
            ];
        };
        ${vars.hostNames.desktop} = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            specialArgs = { inherit inputs; };
            modules = [
                ./modules/desktop/config.nix
                home-manager.nixosModules.home-manager {
                    home-manager = {
                        useGlobalPkgs = true;
                        useUserPackages = true;
                        users.${vars.userName}.imports = [
                            ./modules/desktop/home.nix
                            inputs.sops-nix.homeManagerModule
                        ];
                        extraSpecialArgs = { inherit inputs; };
                        sharedModules = [sops-nix.homeManagerModules.sops ];
                    };
                }
                sops-nix.nixosModules.sops
                disko.nixosModules.disko
                lix.nixosModules.default
            ];
        };
    };
};
}
