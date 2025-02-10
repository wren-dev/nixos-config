{ config, pkgs, inputs, ... }: let
    vars = import ./vars.nix;
in {

networking.firewall.allowedTCPPorts = [ 9022 ];
services.openssh = {
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
services.fail2ban = {
    enable = true;
    maxretry = 3;
    ignoreIP = [
        "10.0.0.0/8" "172.16.0.0/12" "192.168.0.0/16" "127.0.0.1"
        "100.117.243.126" "100.103.251.85" "100.87.171.106"
    ];
    bantime = "200h";
};

}
