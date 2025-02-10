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
    nix-on-droid = {
        url = "github:nix-community/nix-on-droid/release-24.05";
        inputs.nixpkgs.follows = "nixpkgs";
    };
    apple-fonts = {
        url = "git+ssh://git@gitlab.com/wren-dev-nix/apple-fonts.git";
        inputs.nixpkgs.follows = "nixpkgs";
    };
};

outputs = inputs@{ nixpkgs, home-manager, sops-nix, disko, lix, nix-on-droid, ... }: let
    vars = import ./modules/vars.nix;
in {
    nixosConfigurations = {
        ${vars.hostNames.laptop} = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            specialArgs = { inherit inputs; };
            modules = [
                ./modules/host/laptop/config.nix
                home-manager.nixosModules.home-manager {
                    home-manager = {
                        useGlobalPkgs = true;
                        useUserPackages = true;
                        users.${vars.userName}.imports = [
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
                ./modules/host/desktop/config.nix
                home-manager.nixosModules.home-manager {
                    home-manager = {
                        useGlobalPkgs = true;
                        useUserPackages = true;
                        users.${vars.userName}.imports = [
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
    nixOnDroidConfigurations.default = nix-on-droid.lib.nixOnDroidConfiguration {
        pkgs = import nixpkgs { system = "aarch64-linux"; };
        modules = [ ./modules/host/android/config.nix ];
    };
};
}
