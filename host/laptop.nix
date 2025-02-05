{ config, pkgs, inputs, ... }: {

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
    hostName = "ren-laptop"; # Define your hostname.
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
    user = "ren";
};

#}}}

#{{{ Services

services.printing.enable = true;

#}}}


}
