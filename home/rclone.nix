{ config, pkgs, inputs, sops-nix, lib, ... }: let
    vars = import ./../vars.nix;
in {

home.activation.rclone = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p ${config.home.homeDirectory}/mnt/dropbox
'';

sops.secrets.dropbox-token = {};
sops.secrets.mega-username = {};
sops.secrets.mega-password = {};
sops.secrets.proton-config = {};
sops.secrets.gdrive-config = {};
sops.templates."rclone.conf".content = ''
    [dropbox]
    type = dropbox
    token = ${config.sops.placeholder.dropbox-token}

    [mega]
    type = mega
    user = ${config.sops.placeholder.mega-username}
    pass = ${config.sops.placeholder.mega-password}

    [proton]
    ${config.sops.placeholder.proton-config}

    [gdrive]
    ${config.sops.placeholder.gdrive-config}
'';
xdg.configFile."rclone/rclone.conf".source = config.lib.file.mkOutOfStoreSymlink "${config.sops.templates."rclone.conf".path}";
systemd.user.services.rclone-dropbox = {
    Unit = {
        Description = "Rclone mount: dropbox";
        After = "network-online.target";
        StartLimitInterval = 200;
        StartLimitBurst = 2;
    };
    Install = {
        WantedBy = [ "default.target" ];
    };
    Service = {
        ExecStart = ''
        ${pkgs.rclone}/bin/rclone mount --allow-other --vfs-cache-mode full --cache-dir ${config.home.homeDirectory}/.local/cache dropbox: ${config.home.homeDirectory}/mnt/dropbox
        '';
        ExecStop = ''
            /run/wrappers/bin/fusermount -zu ${config.home.homeDirectory}/mnt/dropbox
    '';
    Environment = [ "PATH=/run/wrappers/bin/:$PATH" ];
    };
};




}
