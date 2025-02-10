{ config, pkgs, inputs, ... }: let
    vars = import ./vars.nix;
in {

imports = [
    inputs.sops-nix.nixosModules.sops
];

sops = {
    defaultSopsFile = ./../res/secrets.yaml;
    validateSopsFiles = false;
    age = {
        sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
        keyFile = "/var/lib/sops-nix/key.txt";
        generateKey = true;
    };
};

environment.systemPackages = [
    pkgs.age
    pkgs.sops
    pkgs.ssh-to-age
];

home-manager.users.${vars.userName} = { config, pkgs, inputs, sops-nix, lib, ... }: {
    systemd.user.services.mbsync.Unit.After = [ "sops-nix.service" ];
    sops = {
        age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
        defaultSopsFile = ./../res/secrets.yaml;
        defaultSymlinkPath = "/run/user/1000/secrets";
        defaultSecretsMountPoint = "/run/user/1000/secrets.d";
    };
};

}
