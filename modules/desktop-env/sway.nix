# vim vim: set ts=4 sw=4 et fdm=marker :
{ config, pkgs, inputs, ... }: let
    vars = import ./../vars.nix;
in {

imports = [
    ./audio.nix
    ./programs.nix
];

environment.systemPackages = [ pkgs.cage ];

services.gnome.gnome-keyring.enable = true;

programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
};

programs.regreet = {
    enable = true;
}

services.greetd = {
    enable = true;
    settings = {
        default_session = {
            command = "${pkgs.cage}/bin/cage ${pkgs.regreet}/bin/regreet";
            user = "greeter";
        };
    };
environment.etc."greetd/environments".text = ''
    sway
    bash
'';
};

}
