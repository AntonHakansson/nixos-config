{ config, lib, pkgs, ... }:

{
  options.asdf.graphical.audio.enable = lib.mkEnableOption "audio";

  config = lib.mkIf config.asdf.graphical.audio.enable {
    asdf.core.zfs.homeCacheLinks = [ ".local/state/wireplumber" ];

    home-manager.users.hakanssn = { ... }: {
      home.packages = with pkgs; [ pavucontrol ];
    };

    sound.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };
  };
}
