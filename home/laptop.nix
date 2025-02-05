{ config, pkgs, inputs, sops-nix, lib, ... }: {
imports = [
    ./common.nix
    ./rclone.nix
];
}
