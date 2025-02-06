# vim vim: set ts=4 sw=4 et fdm=marker :

#TODOL: Encrypted swap, BTRFS
{ config, lib, pkgs, modulesPath, inputs, ... }: let
    vars = import ./../vars.nix;
in {

disko.devices.disk.internal.type = "disk";
disko.devices.disk.internal.device = "/dev/mmcblk0";
disko.devices.disk.internal.content = {
    type = "gpt";
    partitions = {
        ESP = {
            type = "EF00";
            size = "500M";
            content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
            };
        };
        SWAP = {
            size = "4G";
            content = { type = "swap"; };
        };
        root = {
            size = "100%";
            content = {
                type = "lvm_pv";
                vg = "root_vg";
            };
        };
    };
};
disko.devices.disk.sdcard.type = "disk";
disko.devices.disk.sdcard.device = "/dev/mmcblk1";
disko.devices.disk.sdcard.content = {
    type = "gpt";
    partitions = {
        sd_lvm = {
            size = "100%";
            content = {
                type = "lvm_pv";
                vg = "sd_vg";
            };
        };
    };
};
disko.devices.lvm_vg.root_vg.type = "lvm_vg";
disko.devices.lvm_vg.root_vg.lvs.root = {
    size = "100%FREE";
    content = {
        type = "btrfs";
        extraArgs = ["-f"];
        subvolumes = {
            "/root" = {
                mountpoint = "/";
            };
            "/persist" = {
                mountOptions = ["subvol=persist" "noatime"];
                mountpoint = "/persist";
            };
            "/nix" = {
                mountOptions = ["subvol=nix" "noatime"];
                mountpoint = "/nix";
            };
        };
    };
};
disko.devices.lvm_vg.sd_vg.type = "lvm_vg";
disko.devices.lvm_vg.sd_vg.lvs.sdcard = {
    size = "100%FREE";
    content = {
        type = "btrfs";
        extraArgs = ["-f"];
        subvolumes = {
            "/home" = {
                mountOptions = ["subvol=home" "noatime"];
                mountpoint = "/home";
            };
            "/home/persist" = {
                mountOptions = ["subvol=home_persist" "noatime"];
                mountpoint = "/home/persist";
            };
        };
    };
};

}
