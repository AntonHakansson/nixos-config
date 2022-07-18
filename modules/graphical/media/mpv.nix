{ config, lib, pkgs, ... }:

{
  config = lib.mkIf config.hakanssn.graphical.media.mpv.enable {
    home-manager.users.hakanssn = { ... }: {
      programs.mpv = {
        enable = true;
        config = {
          # Saves the seekbar position on exit
          save-position-on-quit = "yes";

          # Uses a large seekable RAM cache even for local input.
          cache = "yes";
          # cache-secs=300
          # Uses extra large RAM cache (needs cache=yes to make it useful).
          demuxer-max-bytes = "800M";
          demuxer-max-back-bytes = "200M";

          # Load external audio with (almost) the same name as the video
          audio-file-auto = "fuzzy";

          # Load external subtitles with (almost) the same name as the video
          sub-auto = "fuzzy";
          # search for external subs in the listed subdirectories
          sub-file-paths = "ass:srt:sub:subs:subtitles";

          osd-scale = 1;
          osd-font-size = 55;
        };
        profiles = {
          "extension.gif" = {
            cache = "no";
            loop-file = "yes";
          };
          "extension.webm" = { loop-file = "yes"; };
        };
        bindings = {
          l = "seek 5";
          h = "seek -5";

          ">" = "add speed 0.25";
          "<" = "add speed -0.25";

          "Ctrl+n" = "playlist-next";
          "Ctrl+p" = "playlist-prev";
          PGUP = "playlist-prev";
          PGDWN = "playlist-next";
        };
      };
    };
  };
}
