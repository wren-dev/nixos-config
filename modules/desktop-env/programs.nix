# vim vim: set ts=4 sw=4 et fdm=marker :
{ config, pkgs, inputs, ... }: let
    vars = import ./../vars.nix;
in {

imports = [
    ./neovim.nix
    ./firefox.nix
];

users.users.${vars.userName}.packages = with pkgs; [
    # GUI Apps
    keepassxc

    # Development
    gcc gnumake
    treefmt emacs

    # Nix Utils
    nix-tree nix-melt nix-index nix-du nix-diff
    nh manix nvd cached-nix-shell
    nix-output-monitor statix
];

home-manager.users.${vars.userName} = { config, pkgs, inputs, sops-nix, lib, ... }: {
    programs.git = {
        enable = true;
        userName  = vars.gitUserName;
        userEmail = vars.email;
        extraConfig.init.defaultBranch = "main";
    };
};

}
