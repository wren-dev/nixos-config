# vim vim: set ts=4 sw=4 et fdm=marker :
{ config, pkgs, inputs, ... }: let
    vars = import ./vars.nix;
in {

#{{{ Basic Stuff
imports = [
    inputs.sops-nix.nixosModules.sops
];
nix.settings.experimental-features = [ "nix-command" "flakes" ];
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
        ports = [ 22 ];
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
        ];
        bantime = "72h";
    };
};

sops.secrets.cloudflare-token = {};
services.cloudflare-dyndns = {
    enable = false;
    domains = [ "???.wren-homepage.online" ];
    apiTokenFile = config.sops.secrets.cloudflare-token.path;
};

#}}}

#{{{ Tailscale


# https://login.tailscale.com/admin/settings/authkeys
sops.secrets.tailscale-token = {};

services.tailscale.enable = true;
systemd.services.tailscale-autoconnect = {
    description = "Automatic connection to Tailscale";

    # make sure tailscale is running before trying to connect to tailscale
    after = [ "network-pre.target" "tailscale.service" ];
    wants = [ "network-pre.target" "tailscale.service" ];
    wantedBy = [ "multi-user.target" ];

    # set this service as a oneshot job
    serviceConfig.Type = "oneshot";

    # have the job run this shell script
    script = with pkgs; ''
        echo "Waiting for tailscale.service start completion ..." 
        sleep 5

        echo "Checking if already authenticated to Tailscale ..."
        status="$(${tailscale}/bin/tailscale status -json | ${jq}/bin/jq -r .BackendState)"
        if [ $status = "Running" ]; then  # do nothing
            echo "Already authenticated to Tailscale, exiting."
            exit 0
        fi

        # otherwise authenticate with tailscale
        echo "Authenticating with Tailscale ..."
        ${tailscale}/bin/tailscale up --auth-key file:${config.sops.secrets.tailscale-token.path}
    '';
};
#}}}

#{{{ Users
sops.secrets.machine-password.neededForUsers = true;
users = {
    mutableUsers = false;
    users.${vars.userName} = {
        isNormalUser = true;
        description = vars.userName;
        extraGroups = [ "networkmanager" "wheel" ];
        packages = with pkgs; [
        #  thunderbird
        ];
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
    git
    wget
    rclone
    age
    sops
    ssh-to-age
    cloudflare-dyndns
    tailscale
    statix
    nvd
    cached-nix-shell
    nix-tree
    nix-output-monitor
    nix-melt
    nix-index
    nix-du
    nix-diff
    nh
    manix
    gnumake
    gcc
    unzip
    ripgrep
    keepassxc
    tmux
    sshfs
];
#}}}

}
