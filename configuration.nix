{ config, pkgs, inputs, ... }: {

#{{{ Basic Stuff
imports = [
    ./hardware-configuration.nix
    inputs.sops-nix.nixosModules.sops
];
system.stateVersion = "24.11"; # Did you read the comment?
nix.settings.experimental-features = [ "nix-command" "flakes" ];
nixpkgs.config.allowUnfree = true;
time.timeZone = "America/Chicago";
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
    defaultSopsFile = ./secrets.yaml;
    validateSopsFiles = false;
    age = {
        sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
        keyFile = "/var/lib/sops-nix/key.txt";
        generateKey = true;
    };
};
#}}}

#{{{ Bootloader
boot.loader.systemd-boot.enable = true;
boot.loader.efi.canTouchEfiVariables = true;
#}}}

#{{{ Networking
networking = {
    hostName = "ren-laptop"; # Define your hostname.
    networkmanager.enable = true;
    firewall.allowedTCPPorts = [ 22 53 ];
    firewall.allowedUDPPorts = [ 53 ];
};
#}}}

#{{{ Desktop Environment 
services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
    xkb = {
        layout = "us";
        variant = "";
    };
};
services.displayManager.autoLogin = {
    enable = true;
    user = "ren";
};

#}}}

#{{{ Services
security.rtkit.enable = true;
services = {
    printing.enable = true;
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
            AllowUsers = [ "ren" ];
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
    domains = [ "laptop.wren-homepage.online" ];
    apiTokenFile = config.sops.secrets.cloudflare-token.path;
};

#}}}

#{{{ Users
sops.secrets.machine-password.neededForUsers = true;
users = {
    mutableUsers = false;
    users.ren = {
        isNormalUser = true;
        description = "ren";
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
];
#}}}

}
