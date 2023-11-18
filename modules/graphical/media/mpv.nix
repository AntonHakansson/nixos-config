{ config, lib, pkgs, ... }:

{
  options.hakanssn.graphical.media = { mpv.enable = lib.mkEnableOption "mpv"; };

  config = lib.mkIf config.hakanssn.graphical.media.mpv.enable {
    home-manager.users.hakanssn = { ... }: {
      programs.mpv = {
        enable = true;
        scripts = [
          pkgs.mpvScripts.uosc         # Friendly UI.
          pkgs.mpvScripts.quality-menu # Change ytdl-format on the fly.
          pkgs.mpvScripts.acompressor  # Dynamic range compression filter.
          pkgs.mpvScripts.mpv-playlistmanager
        ];
        config = {
          vo = "gpu-next";
          profile = "gpu-hq";

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

          # OSC/OSD is replaced with uosc plugin
          osc = "no";
          osd-bar = "no";
          border = "no";
        };
        profiles = {
          "extension.gif" = {
            cache = "no";
            loop-file = "yes";
          };
          "extension.webm" = { loop-file = "yes"; };
        };
        bindings = {
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
