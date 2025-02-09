# vim vim: set ts=4 sw=4 et fdm=marker :
{ config, lib, pkgs, modulesPath, inputs, ... }: let
    vars = import ./../vars.nix;
in {

#{{{ Basic Stuff
imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ./disko.nix
    ./../common.nix
    ./../sops.nix
    ./../tailscale.nix
    ./../firefox.nix
    ./../neovim.nix
];
system.stateVersion = "24.11"; # Did you read the comment?
time.timeZone = "America/Chicago";
nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
#}}}

#{{{ Boot
boot.loader.systemd-boot.enable = true;
boot.loader.efi.canTouchEfiVariables = true;
boot.initrd.availableKernelModules = [ "ahci" "xhci_pci" "usb_storage" "sd_mod" "sdhci_pci" "rtsx_usb_sdmmc" ];
boot.initrd.kernelModules = [ "dm-snapshot" ];
boot.kernelModules = [ "kvm-intel" ];
boot.extraModulePackages = [ ];
#}}}

#{{{ Networking
networking = {
    useDHCP = lib.mkDefault true;
    hostName = vars.hostNames.laptop; # Define your hostname.
    networkmanager.enable = true;
    firewall.allowedTCPPorts = [ 9022 ];
    firewall.allowedUDPPorts = [ config.services.tailscale.port ];
};
#}}}

#{{{ Desktop Environment 
services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
    xkb = {
        layout = "us";
        variant = "";
    };
};
services.displayManager.autoLogin = {
    enable = true;
    user = vars.userName;
};

#}}}

#{{{ Services

services.printing.enable = true;

#}}}


}
