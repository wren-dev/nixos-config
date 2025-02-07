# vim vim: set ts=4 sw=4 et fdm=marker :

{

# Internal SSD Disk
disko.devices.disk.ssd_internal.type = "disk";
disko.devices.disk.ssd_internal.device = "/dev/disk/by-id/ata-SATA_SSD_19082224000357";
disko.devices.disk.ssd_internal.content = {
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
            size = "16G";
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

# Loosely connected SSD
disko.devices.disk.ssd_loose.type = "disk";
disko.devices.disk.ssd_loose.device = "/dev/disk/by-id/wwn-0x5f8db4c1417010b2";
disko.devices.disk.ssd_loose.content = {
    type = "gpt";
    partitions = {
        sd_lvm = {
            size = "100%";
            content = {
                type = "lvm_pv";
                vg = "home_vg";
            };
        };
    };
};

# Internal SSD VG
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
disko.devices.lvm_vg.home_vg.type = "lvm_vg";
disko.devices.lvm_vg.home_vg.lvs.loosessd = {
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
