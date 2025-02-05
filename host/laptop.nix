# vim vim: set ts=4 sw=4 et fdm=marker :
{ config, pkgs, inputs, ... }: let
    vars = import ./../vars.nix;
in {

#{{{ Basic Stuff
imports = [
    ./hardware-configuration.nix
    ./common.nix
];
system.stateVersion = "24.11"; # Did you read the comment?
time.timeZone = "America/Chicago";
#}}}

#{{{ Bootloader
boot.loader.systemd-boot.enable = true;
boot.loader.efi.canTouchEfiVariables = true;
#}}}

#{{{ Networking
networking = {
    hostName = vars.hostNames.laptop; # Define your hostname.
    networkmanager.enable = true;
    firewall.allowedTCPPorts = [ 22 53 ];
    firewall.allowedUDPPorts = [ 53 ];
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
