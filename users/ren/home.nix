{ config, pkgs, inputs, ... }: {
  imports = [
    inputs.sops-nix.homeManagerModules.sops
  ];
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

    sops = {
    age.keyFile = "/home/ren/.config/sops/age/keys.txt";


    defaultSopsFile = ../../secrets.yaml;
    validateSopsFiles = false;
    };
    # xdg.configFile."rclone/rclone.conf".source = config.sops.secrets."rclone-dropbox".path;

    home.stateVersion = "24.11";
    programs.home-manager.enable = true;
}
