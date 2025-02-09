# vim vim: set ts=4 sw=4 et fdm=marker :
{ config, lib, pkgs, modulesPath, inputs, ... }: let
    vars = import ./../../vars.nix;
in {

#{{{ Basic Stuff
imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ./../../common.nix
    ./../../sops.nix
    ./../../tailscale.nix
    ./disko.nix
    ./ddns.nix
];
system.stateVersion = "24.11"; # Did you read the comment?
time.timeZone = "America/Chicago";
nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
# Allow building aarch64 pkgs
boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
#}}}

#{{{ Boot
boot.loader.systemd-boot.enable = true;
boot.loader.efi.canTouchEfiVariables = true;
boot.initrd.availableKernelModules = [ "ahci" "xhci_pci" "usb_storage" "sd_mod" "usbhid" ];
boot.initrd.kernelModules = [ "dm-snapshot" ];
boot.kernelModules = [ "kvm-amd" ];
boot.extraModulePackages = [ ];
#}}}

#{{{ Fucking stop suspending
systemd = {
    targets = {
        sleep = {
            enable = false;
            unitConfig.DefaultDependencies = "no";
        };
        suspend = {
            enable = false;
            unitConfig.DefaultDependencies = "no";
        };
        hibernate = {
            enable = false;
            unitConfig.DefaultDependencies = "no";
        };
        "hybrid-sleep" = {
            enable = false;
            unitConfig.DefaultDependencies = "no";
        };
    };
}; 
#}}}

#{{{ Networking
networking = {
    useDHCP = lib.mkDefault true;
    hostName = vars.hostNames.desktop;
    networkmanager.enable = true;
    firewall.allowedTCPPorts = [ 9022 ];
    firewall.allowedUDPPorts = [ config.services.tailscale.port ];
};

#}}}
}
