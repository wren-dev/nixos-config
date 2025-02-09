{config, pkgs, ...}: {

environment.systemPackages = [ pkgs.tailscale ];

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

networking.extraHosts = ''
    100.117.243.126 ts-desktop
    100.103.251.85  ts-laptop
    100.87.171.106 ts-phone
'';
}
