{ config, lib, pkgs, .. }: {

time.timeZone = "America/Chicago";
system.stateVersion = "24.05";
nix.extraOptions = ''
    experimental-features = nix-command flakes
'';
# Backup etc files instead of failing to activate
environment.etcBackupExtension = ".bak";

user.uid = 10279;
user.gid = 10279;

environment.packages = with pkgs; [
    neovim
    rsync
    git
    openssh

    #Very basic stuff
    procps
    killall
    diffutils
    findutils
    utillinux
    tzdata
    hostname
    man
    gnugrep
    gnupg
    gnused
    gnutar
    bzip2
    gzip
    xz
    zip
    unzip
];

}
