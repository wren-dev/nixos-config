# vim vim: set ts=4 sw=4 et fdm=marker :
{ config, pkgs, inputs, sops-nix, lib, ... }: let
    vars = import ./../vars.nix;
in {

home.activation.rclone = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p ${config.home.homeDirectory}/mnt/dropbox
    mkdir -p ${config.home.homeDirectory}/mnt/mega
    mkdir -p ${config.home.homeDirectory}/mnt/proton
    mkdir -p ${config.home.homeDirectory}/mnt/gdrive

'';

sops.secrets.dropbox-token = {};
sops.secrets.mega-username = {};
sops.secrets.mega-password = {};
sops.secrets.proton-config = {};
sops.secrets.gdrive-config = {};

#{{{ Rclone.conf
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
#}}}

#{{{ rclone-dropbox.service
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
        Restart= "on-failure";
        RestartSec = 30;
        ExecStart = ''
        ${pkgs.rclone}/bin/rclone mount --allow-other --vfs-cache-mode full --cache-dir ${config.home.homeDirectory}/.local/cache dropbox: ${config.home.homeDirectory}/mnt/dropbox
        '';
        ExecStop = ''
            /run/wrappers/bin/fusermount -zu ${config.home.homeDirectory}/mnt/dropbox
    '';
    Environment = [ "PATH=/run/wrappers/bin/:$PATH" ];
    };
};
#}}}

#{{{ rclone-mega.service
systemd.user.services.rclone-mega = {
    Unit = {
        Description = "Rclone mount: mega";
        After = "network-online.target";
        StartLimitInterval = 200;
        StartLimitBurst = 2;
    };
    Install = {
        WantedBy = [ "default.target" ];
    };
    Service = {
        Restart= "on-failure";
        RestartSec = 30;
        ExecStart = ''
        ${pkgs.rclone}/bin/rclone mount --allow-other --vfs-cache-mode full --cache-dir ${config.home.homeDirectory}/.local/cache mega: ${config.home.homeDirectory}/mnt/mega
        '';
        ExecStop = ''
            /run/wrappers/bin/fusermount -zu ${config.home.homeDirectory}/mnt/mega
    '';
    Environment = [ "PATH=/run/wrappers/bin/:$PATH" ];
    };
};
#}}}

#{{{ rclone-proton.service
systemd.user.services.rclone-proton = {
    Unit = {
        Description = "Rclone mount: proton";
        After = "network-online.target";
        StartLimitInterval = 200;
        StartLimitBurst = 2;
    };
    Install = {
        WantedBy = [ "default.target" ];
    };
    Service = {
        Restart= "on-failure";
        RestartSec = 30;
        ExecStart = ''
        ${pkgs.rclone}/bin/rclone --config ${config.home.homeDirectory}/.config/rclone/rclone.conf mount --allow-other --vfs-cache-mode full --cache-dir ${config.home.homeDirectory}/.local/cache proton: ${config.home.homeDirectory}/mnt/proton
        '';
        ExecStop = ''
            /run/wrappers/bin/fusermount -zu ${config.home.homeDirectory}/mnt/proton
    '';
    Environment = [ "PATH=/run/wrappers/bin/:$PATH" ];
    };
};
#}}}

#{{{ rclone-gdrive.service
systemd.user.services.rclone-gdrive = {
    Unit = {
        Description = "Rclone mount: gdrive";
        After = "network-online.target";
        StartLimitInterval = 200;
        StartLimitBurst = 2;
    };
    Install = {
        WantedBy = [ "default.target" ];
    };
    Service = {
        Restart= "on-failure";
        RestartSec = 30;
        ExecStart = ''
        ${pkgs.rclone}/bin/rclone mount --allow-other --vfs-cache-mode full --cache-dir ${config.home.homeDirectory}/.local/cache gdrive: ${config.home.homeDirectory}/mnt/gdrive
        '';
        ExecStop = ''
            /run/wrappers/bin/fusermount -zu ${config.home.homeDirectory}/mnt/gdrive
    '';
    Environment = [ "PATH=/run/wrappers/bin/:$PATH" ];
    };
};
#}}}


}
