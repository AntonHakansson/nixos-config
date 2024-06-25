{ config, lib, pkgs, ... }:

{
  options.hakanssn.graphical.audio.enable = lib.mkEnableOption "audio";

  config = lib.mkIf config.hakanssn.graphical.audio.enable {

    home-manager.users.hakanssn = { ... }: {
      home.packages = with pkgs; [ pavucontrol ];
    };

    services.pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };
  };
}
