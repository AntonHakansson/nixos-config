{ config, lib, pkgs, ... }:

{
  options.asdf.graphical.audio.enable = lib.mkOption {
    default = false;
    example = true;
  };

  config = lib.mkIf config.asdf.graphical.audio.enable {
    asdf.core.zfs.homeLinks = [{
      path = ".local/state/wireplumber";
      type = "cache";
    }];

    home-manager.users.hakanssn = { ... }: {
      home.packages = with pkgs;
        [
          pavucontrol
        ];
    };

    sound.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };
  };
}
