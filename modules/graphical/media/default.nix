{ config, lib, pkgs, ... }:

{
  imports = [ ./mpv.nix ./documents.nix ];

  options.asdf.graphical.media = {
    documents.enable = lib.mkEnableOption "document readers";
    mpv.enable = lib.mkEnableOption "mpv";
    recording.enable = lib.mkEnableOption "recording";
    spotify.enable = lib.mkEnableOption "spotify client";
  };

  config = {
    asdf.core.zfs.homeCacheLinks = [ ".config/obs-studio" ];

    home-manager.users.hakanssn = { ... }: {
      home.packages = with pkgs;
        (lib.optionals config.asdf.graphical.media.spotify.enable [
          (ncspot.override {
            withALSA = false;
            withPulseAudio = true;
          })
        ]) ++ (lib.optionals config.asdf.graphical.media.recording.enable
          [ obs-studio ]);
    };
  };
}
