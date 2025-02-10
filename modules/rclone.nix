# vim vim: set ts=4 sw=4 et fdm=marker :
# TODO: Refactor services into single fn for brevity
{ config, lib, pkgs, inputs, ... }: let
    vars = import ./vars.nix;
    mkRcloneService = remote : {
            Unit = {
                Description = "Rclone mount: ${remote}";
                After = "network-online.target";
                StartLimitIntervalSec = 200;
                StartLimitBurst = 1;
            };
            Install = { WantedBy = [ "default.target" ]; };
            Service = {
                Restart= "on-failure";
                RestartSec = 30;
                ExecStart = ''
                    ${pkgs.rclone}/bin/rclone mount --allow-other --vfs-cache-mode full --cache-dir /home/${vars.userName}/.local/cache ${remote}: /home/${vars.userName}/mnt/${remote}
                '';
                ExecStop = ''
                    /run/wrappers/bin/fusermount -zu /home/${vars.userName}/mnt/dropbox
                '';
                Environment = [ "PATH=/run/wrappers/bin/:$PATH" ];
            };
    }; #}}}
in {

programs.fuse.userAllowOther = true;
environment.systemPackages = [ pkgs.rclone ];

#{{{ Home Manager
home-manager.users.${vars.userName} = { config, pkgs, inputs, sops-nix, lib, ...}: {
    home.activation.rclone = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        mkdir -p ${config.home.homeDirectory}/mnt/dropbox
        mkdir -p ${config.home.homeDirectory}/mnt/mega
        mkdir -p ${config.home.homeDirectory}/mnt/proton
        mkdir -p ${config.home.homeDirectory}/mnt/gdrive
    '';

    sops.secrets.dropbox-token = {};
    sops.secrets.mega-username = {};
    sops.secrets.mega-password = {};
    sops.secrets.proton-username = {};
    sops.secrets.proton-password = {};
    sops.secrets.gdrive-clientid = {};
    sops.secrets.gdrive-clientsecret = {};
    sops.secrets.gdrive-token = {};

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
        type = protondrive
        username = ${config.sops.placeholder.proton-username}
        password = ${config.sops.placeholder.proton-password}

        [gdrive]
        type = drive
        client-id = ${config.sops.placeholder.gdrive-clientid}
        client-secret = ${config.sops.placeholder.gdrive-clientsecret}
        scope = drive
        token = ${config.sops.placeholder.gdrive-token}
        team_drive =
    '';
    xdg.configFile."rclone/rclone.conf".source = config.lib.file.mkOutOfStoreSymlink "${config.sops.templates."rclone.conf".path}";
    #}}}

    systemd.user.services.rclone-dropbox = mkRcloneService "dropbox";
    systemd.user.services.rclone-mega = mkRcloneService "mega";
    # Override command for proton because rclone
    #   keeps trying to write to the immutable config file
    systemd.user.services.rclone-proton = mkRcloneService "proton" // {
        Service.ExecStart = ''
            ${pkgs.rclone}/bin/rclone --config /dev/null mount --allow-other --vfs-cache-mode full --cache-dir /home/${vars.userName}/.local/cache --protondrive-username "${config.sops.secrets.proton-username.content}" --protondrive-password "${config.sops.secrets.proton-password.content}" :protondrive: /home/${vars.userName}/mnt/proton
        '';
    };
    systemd.user.services.rclone-gdrive = mkRcloneService "gdrive";


}; #}}}

}
