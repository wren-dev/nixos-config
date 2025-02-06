# vim vim: set ts=4 sw=4 et fdm=marker :

#TODOL: Encrypted swap, BTRFS
{ config, lib, pkgs, modulesPath, inputs, ... }: let
    vars = import ./../vars.nix;
in {
disko.devices = {
    disk = {
        internal = {
            device = "/dev/mmcblk0";
            type = "disk";
            content = {
                type = "gpt";
                partitions = {
                    ESP = {
                        type = "EF00";
                        size = "100M";
                        content = {
                            type = "filesystem";
                            format = "vfat";
                            mountpoint = "/boot";
                            mountOptions = [ "umask=0077" ];
                        };
                    };
                    SWAP = {
                        size = "8G";
                        content = {
                            type = "swap";
                        };
                    };
                    root = {
                        size = "100%";
                        content = {
                            type = "filesystem";
                            format = "ext4";
                            mountpoint = "/";
                        };
                    };
                };
            };
        };
    };
};
}
