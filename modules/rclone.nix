# vim vim: set ts=4 sw=4 et fdm=marker :
{ config, lib, inputs, ... }: let
    vars = import ./vars.nix;
in {

home-manager.users.${vars.userName} = { config, pkgs, inputs, sops-nix, lib, ...}: {
    home.activation.rclone = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        mkdir -p ${config.home.homeDirectory}/mnt/dropbox
        mkdir -p ${config.home.homeDirectory}/mnt/mega
        mkdir -p ${config.home.homeDirectory}/mnt/proton
        mkdir -p ${config.home.homeDirectory}/mnt/gdrive

    '';
};

}
