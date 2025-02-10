{ config, pkgs, inputs, ... }: {
security.rtkit.enable = true; #Needed for pipewire?
services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
};
}
