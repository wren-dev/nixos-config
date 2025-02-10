# vim vim: set ts=4 sw=4 et fdm=marker :
# TODO: Refactor services into single fn for brevity
{ config, lib, pkgs, inputs, ... }: let
    vars = import ./../vars.nix;
    # {{{ Helper function
    mkRcloneService = remote : {
            Unit = {
                Description = "Rclone mount: ${remote}";
                After = "network-online.target graphical.target";
                StartLimitIntervalSec = 200;
                StartLimitBurst = 1;
            };
            Install = { WantedBy = [ "default.target" ]; };
            Service = {
                Restart= "always";
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

        [gdrive]
        ${config.sops.placeholder.gdrive-config}
    '';
    xdg.configFile."rclone/rclone.conf".source = config.lib.file.mkOutOfStoreSymlink "${config.sops.templates."rclone.conf".path}";
    #}}}

    systemd.user.services.rclone-dropbox = mkRcloneService "dropbox";
    systemd.user.services.rclone-mega = mkRcloneService "mega";
    systemd.user.services.rclone-gdrive = mkRcloneService "gdrive";

    # Override command for proton because rclone
    #   keeps trying to write to the immutable config file
    sops.templates.rclone-protonenv.content = ''
        PROTON_USER=${config.sops.placeholder.proton-username}
        PROTON_PASS=${config.sops.placeholder.proton-password}
        PATH=/run/wrappers/bin/:$PATH
    '';
    systemd.user.services.rclone-proton = mkRcloneService "proton" // {
        Service.Restart= "always";
        Service.RestartSec = 30;
        Service.EnvironmentFile =  config.sops.templates.rclone-protonenv.path;
        Service.ExecStart = ''
            ${pkgs.rclone}/bin/rclone --config /dev/null mount --allow-other --vfs-cache-mode full --cache-dir /home/${vars.userName}/.local/cache --protondrive-username $PROTON_USER --protondrive-password $PROTON_PASS :protondrive: /home/${vars.userName}/mnt/proton
        '';
        Service.ExecStop = ''
            /run/wrappers/bin/fusermount -zu /home/${vars.userName}/mnt/dropbox
        '';
    };


}; #}}}

}
