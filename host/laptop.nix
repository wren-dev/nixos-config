{ config, pkgs, inputs, ... }: {

#{{{ Basic Stuff
imports = [
    ./hardware-configuration.nix
    ./common.nix
];
system.stateVersion = "24.11"; # Did you read the comment?
time.timeZone = "America/Chicago";
#}}}

}
