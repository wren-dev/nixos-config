{ config, pkgs, ... }: {
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

    home.stateVersion = "24.11";
    programs.home-manager.enable = true;
}
