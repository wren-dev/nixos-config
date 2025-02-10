# vim vim: set ts=4 sw=4 et fdm=marker :
{ config, pkgs, inputs, ... }: let
    vars = import ./../vars.nix;
in {

imports = [
    ./audio.nix
    ./programs.nix
];

environment.systemPackages = [ pkgs.cage ];
users.users.${vars.userName}.packages = [
    pkgs.wmenu
];

services.gnome.gnome-keyring.enable = true;
security.polkit.enable = true;

programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
};

programs.regreet = {
    enable = true;
};

services.greetd = {
    enable = true;
    settings = {
        default_session = {
            command = "${pkgs.cage}/bin/cage ${pkgs.greetd.regreet}/bin/regreet";
            user = "greeter";
        };
    };
};
environment.etc."greetd/environments".text = ''
    sway
    bash
'';

home-manager.users.${vars.userName} = { config, pkgs, inputs, sops-nix, lib, ... }: {
    xdg.configFile."sway/config".source = ./../../res/config/sway/config;
};

}
