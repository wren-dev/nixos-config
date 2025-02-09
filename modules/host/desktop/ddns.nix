{config, pkgs, ...}: {
sops.secrets.cloudflare-token = {};
services.cloudflare-dyndns = {
    enable = true;
    domains = [ "desktop.wren-homepage.online" ];
    apiTokenFile = config.sops.secrets.cloudflare-token.path;
};

environment.systemPackages = [ pkgs.cloudflare-dyndns ];

}
