{ config, pkgs, inputs, ... }: let
    vars = import ./../vars.nix;
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
    defaultSopsFile = ./../secrets.yaml;
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
            "10.0.0.0/8" "172.16.0.0/12" "192.168.0.0/16"
        ];
        bantime = "72h";
    };
    tailscale.enable = false;
};

sops.secrets.cloudflare-token = {};
services.cloudflare-dyndns = {
    enable = false;
    domains = [ "???.wren-homepage.online" ];
    apiTokenFile = config.sops.secrets.cloudflare-token.path;
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
    cloudflare-dyndns
    tailscale
    statix
    gnumake
    gcc
    unzip
    ripgrep
];
#}}}

}
