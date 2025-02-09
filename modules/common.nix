# vim vim: set ts=4 sw=4 et fdm=marker :
{ config, pkgs, inputs, ... }: let
    vars = import ./vars.nix;
in {

#{{{ Basic Stuff
imports = [
    inputs.sops-nix.nixosModules.sops
];
nix.settings.experimental-features = [ "nix-command" "flakes" ];
nix.settings.trusted-users = [ "root" vars.userName ];
nixpkgs.config.allowUnfree = true;
#{{{ Locale
i18n.defaultLocale = "en_US.UTF-8";

i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
};
#}}}
#}}}

#{{{ Secrets
sops = {
    defaultSopsFile = ./../res/secrets.yaml;
    validateSopsFiles = false;
    age = {
        sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
        keyFile = "/var/lib/sops-nix/key.txt";
        generateKey = true;
    };
};
#}}}

#{{{ Services
security.rtkit.enable = true;
services = {
    pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
    };
    openssh = {
        enable = true;
        ports = [ 9022 ];
        settings = {
            PasswordAuthentication = true;
            AllowUsers = [ vars.userName ];
            UseDns = true;
            X11Forwarding = false;
            PermitRootLogin = "no";
        };
    };
    fail2ban = {
        enable = true;
        maxretry = 5;
        ignoreIP = [
            "10.0.0.0/8" "172.16.0.0/12" "192.168.0.0/16" "127.0.0.1"
            "100.117.243.126" "100.103.251.85" "100.87.171.106"
        ];
        bantime = "72h";
    };
};


#}}}

#{{{ Sudo
security.sudo.wheelNeedsPassword = false;
security.sudo.extraConfig = ''
    # rollback results in sudo lectures after each reboot
    Defaults lecture = never
'';
#}}}

#{{{ Users
sops.secrets.machine-password.neededForUsers = true;
users = {
    mutableUsers = false;
    users.${vars.userName} = {
        isNormalUser = true;
        description = vars.userName;
        extraGroups = [ "networkmanager" "wheel" ];
        hashedPasswordFile = config.sops.secrets.machine-password.path;
    };
    users.root = {
        hashedPasswordFile = config.sops.secrets.machine-password.path;
    };
};

# Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
systemd.services."getty@tty1".enable = false;
systemd.services."autovt@tty1".enable = false;
#}}}

#{{{ Program Modules
programs = {
    firefox.enable = true;
    neovim = {
        enable = true;
        defaultEditor = true;
    };
    fuse.userAllowOther = true;
};
#}}}

#{{{ Sys Packages
environment.systemPackages = with pkgs; [
    # Basic System Utilities
    age sops ssh-to-age
    git wget rclone sshfs
    tmux htop ripgrep
    unzip
    lm_sensors

    # Nix Utils
    nix-tree nix-melt nix-index nix-du nix-diff
    nh manix nvd cached-nix-shell

    # Nix Building
    nix-output-monitor statix
    gcc gnumake
    treefmt emacs

    cloudflare-dyndns
    keepassxc
];
#}}}

}
