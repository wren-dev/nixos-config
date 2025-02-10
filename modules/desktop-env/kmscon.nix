# vim vim: set ts=4 sw=4 et fdm=marker :
{ config, pkgs, lib, inputs, ... }: let
    vars = import ./../vars.nix;
    colors = {
        black = "63, 68, 81";
        red = "224, 85, 97";
	green = "140, 194, 101";
	yellow = "209, 143, 82";
	blue = "74, 165, 240";
	magenta = "193, 98, 222";
	cyan = "66, 179, 194";
	light-grey = "230, 230, 230"; # White
	dark-grey = "79, 86, 102"; # Bright Black
	light-red = "255, 97, 110";
    light-green = "165, 224, 117";
    light-yellow = "240, 164, 93";
	light-blue = "77, 196, 255";
	light-magenta = "222, 115, 255";
	light-cyan = "76, 209, 224";
	white = "215, 218, 224"; # Bright White
	fg = "171, 178, 191";
	bg = "40, 44, 52";
    cursor = "#abb2bf";
    };
in {

fonts.packages = [ pkgs.source-code-pro ];
services.kmscon.enable = true;
services.kmscon.hwRender = true;
services.kmscon.extraConfig = ''
    hwaccel
    font-name=SourceCodePro-Regular
    palette-black=${colors.black}
    palette-red=${colors.red}
    palette-green=${colors.green}
    palette-yellow=${colors.yellow}
    palette-blue=${colors.blue}
    palette-magenta=${colors.magenta}
    palette-cyan=${colors.cyan}
    palette-light-grey=${colors.light-grey}
    palette-dark-grey=${colors.dark-grey}
    palette-light-red=${colors.light-red}
    palette-light-green=${colors.light-green}
    palette-light-yellow=${colors.light-yellow}
    palette-light-blue=${colors.light-blue}
    palette-light-magenta=${colors.light-magenta}
    palette-light-cyan=${colors.light-cyan}
    palette-white=${colors.white}
    palette-foreground=${colors.fg}
    palette-background=${colors.bg}
'';

systemd.services."kmsconvt@tty2".wantedBy = [ "multi-user.target" ];
systemd.services."kmsconvt@tty3".enable = false;
systemd.services."kmsconvt@tty4".enable = false;
systemd.services."kmsconvt@tty5".enable = false;
systemd.services."kmsconvt@tty6".enable = false;
systemd.services."getty@tty2".enable = false;
systemd.services."getty@tty3".enable = false;
systemd.services."getty@tty4".enable = false;
systemd.services."getty@tty5".enable = false;
systemd.services."getty@tty6".enable = false;
systemd.services."getty@tty2".serviceConfig.execStart = lib.mkForce "/usr/bin/env true";
systemd.services."getty@tty3".serviceConfig.execStart = lib.mkForce "/usr/bin/env true";
systemd.services."getty@tty4".serviceConfig.execStart = lib.mkForce "/usr/bin/env true";
systemd.services."getty@tty5".serviceConfig.execStart = lib.mkForce "/usr/bin/env true";
systemd.services."getty@tty6".serviceConfig.execStart = lib.mkForce "/usr/bin/env true";

}
