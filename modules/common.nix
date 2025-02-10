# vim vim: set ts=4 sw=4 et fdm=marker :
{ config, pkgs, inputs, ... }: let
    vars = import ./vars.nix;
in {

nix.settings.experimental-features = [ "nix-command" "flakes" ];
nix.settings.trusted-users = [ "root" vars.userName ];
nixpkgs.config.allowUnfree = true;

#{{{ Locale
i18n.defaultLocale = "en_US.UTF-8";

i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
};
#}}}

#{{{ Sudo
security.sudo.wheelNeedsPassword = false;
security.sudo.extraConfig = ''
    # rollback results in sudo lectures after each reboot
    Defaults lecture = never
'';
#}}}

#{{{ Users
sops.secrets.machine-password.neededForUsers = true;
users = {
    mutableUsers = false;
    users.${vars.userName} = {
        isNormalUser = true;
        description = vars.userName;
        extraGroups = [ "networkmanager" "wheel" ];
        hashedPasswordFile = config.sops.secrets.machine-password.path;
    };
    users.root = {
        hashedPasswordFile = config.sops.secrets.machine-password.path;
    };
};
#}}}

#{{{ Home Manager
home-manager.users.${vars.userName} = { config, pkgs, inputs, sops-nix, lib, ... }: {
    home.username = vars.userName;
    home.homeDirectory = "/home/${vars.userName}";
    home.stateVersion = "24.11";
    programs.home-manager.enable = true;
};
#}}}

#{{{ Sys Packages
environment.systemPackages = with pkgs; [
    # Basic System Utilities
    git wget rsync sshfs openssh
    tmux htop ripgrep vim
    lm_sensors
];
#}}}

}
