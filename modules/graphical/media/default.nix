{ config, lib, pkgs, ... }:

{
  imports = [ ./anki.nix ./mpv.nix ./documents.nix ];

  options.hakanssn.graphical.media = {
    documents.enable = lib.mkEnableOption "document readers";
    mpv.enable = lib.mkEnableOption "mpv";
    recording.enable = lib.mkEnableOption "recording";
    spotify.enable = lib.mkEnableOption "spotify client";
  };

  config = {
    hakanssn.core.zfs.homeCacheLinks = [ ".config/obs-studio" ];

    home-manager.users.hakanssn = { ... }: {
      home.packages = with pkgs;
        (lib.optionals config.hakanssn.graphical.media.spotify.enable [
          (ncspot.override {
            withALSA = false;
            withPulseAudio = true;
          })
        ]) ++ (lib.optionals config.hakanssn.graphical.media.recording.enable
          [ obs-studio ]);
    };
  };
}
