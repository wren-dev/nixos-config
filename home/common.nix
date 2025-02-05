{ config, pkgs, inputs, sops-nix, lib, ... }: {
    home.username = "ren";
    home.homeDirectory = "/home/ren";

    # link all files in `./scripts` to `~/.config/i3/scripts`
    # home.file.".config/i3/scripts" = {
    #     source = ./scripts;
    #     recursive = true;   # link recursively
    #     executable = true;  # make all files executable
    # };

    programs.git = {
        enable = true;
        userName  = "Wren";
        userEmail = "renmain@proton.me";
    extraConfig.init.defaultBranch = "main";
    };

      systemd.user.services.mbsync.Unit.After = [ "sops-nix.service" ];

    home.activation.rclone = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        mkdir -p /home/ren/mnt/dropbox
    '';

    sops = {
    age.keyFile = "/home/ren/.config/sops/age/keys.txt";
    defaultSopsFile = ./../secrets.yaml;
    defaultSymlinkPath = "/run/user/1000/secrets";
    defaultSecretsMountPoint = "/run/user/1000/secrets.d";
    };

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
            ${pkgs.rclone}/bin/rclone mount --allow-other --vfs-cache-mode full --cache-dir /home/ren/.local/cache dropbox: /home/ren/mnt/dropbox
            '';
            ExecStop = ''
                /run/wrappers/bin/fusermount -zu /home/ren/mnt/dropbox
        '';
        Environment = [ "PATH=/run/wrappers/bin/:$PATH" ];
        };
    };

    home.stateVersion = "24.11";
    programs.home-manager.enable = true;
}
