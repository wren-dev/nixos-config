{ config, pkgs, inputs, sops-nix, lib, ... }: let 
    vars = import ./../vars.nix;
in {

#{{{ Basic Stuff
home.username = vars.userName;
home.homeDirectory = "/home/${vars.userName}";
home.stateVersion = "24.11";
programs.home-manager.enable = true;
#}}}

programs.git = {
    enable = true;
    userName  = vars.gitUserName;
    userEmail = vars.email;
extraConfig.init.defaultBranch = "main";
};

#{{{ SOPS
systemd.user.services.mbsync.Unit.After = [ "sops-nix.service" ];
sops = {
    age.keyFile = "${config.home.homeDirectory}/.sops_age_key.txt";
    defaultSopsFile = ./../secrets.yaml;
    defaultSymlinkPath = "/run/user/1000/secrets";
    defaultSecretsMountPoint = "/run/user/1000/secrets.d";
};
#}}}

}
