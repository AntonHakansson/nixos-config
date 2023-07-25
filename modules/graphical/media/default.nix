{ config, lib, pkgs, ... }:

{
  imports = [ ./anki.nix ./mpv.nix ./documents.nix ];

  options.hakanssn.graphical.media = {
    recording.enable = lib.mkEnableOption "recording";
  };

  config = {
    hakanssn.core.zfs.homeCacheLinks = [ ".config/obs-studio" ];

    home-manager.users.hakanssn = { ... }: {
      home.packages = with pkgs;
        (lib.optionals config.hakanssn.graphical.media.recording.enable
          [ obs-studio ]);
    };
  };
}
