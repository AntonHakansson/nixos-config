{ config, lib, pkgs, ... }:

let
  mpv-uosc = pkgs.stdenvNoCC.mkDerivation rec {
    pname = "mpv-uosc";
    version = "4.5.0";

    src = pkgs.fetchzip {
      url =
        "https://github.com/tomasklaen/uosc/releases/download/${version}/uosc.zip";
      sha256 = "sha256-xLT1YgFxMLYyFCxe4mU8slRlCUGMjnJgk6fBNVXT5Dc=";
      stripRoot = false;
    };

    dontBuild = true;
    dontCheck = true;

    postPatch = ''
      substituteInPlace ./scripts/uosc.lua \
        --replace "mp.find_config_file('scripts')" "'$out/share/mpv/scripts'"
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/share/mpv
      ls -la ./fonts ./scripts
      cp -r ./fonts ./scripts $out/share/mpv
      runHook postInstall
    '';

    passthru.scriptName = "uosc.lua";

    meta = with lib; {
      description = "Feature-rich minimalist proximity-based UI for MPV player";
      homepage = "https://github.com/tomasklaen/uosc";
      license = licenses.gpl3;
    };
  };
in
{
  options.hakanssn.graphical.media = { mpv.enable = lib.mkEnableOption "mpv"; };

  config = lib.mkIf config.hakanssn.graphical.media.mpv.enable {
    home-manager.users.hakanssn = { ... }: {
      programs.mpv = {
        enable = true;
        scripts = [
          mpv-uosc
        ];
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
      xdg.configFile."mpv/fonts.conf".text = ''
        <?xml version='1.0'?>
        <!DOCTYPE fontconfig SYSTEM 'fonts.dtd'>
        <fontconfig>
          <!-- icon fonts used by uosc osd -->
          <dir>${mpv-uosc}/share/mpv/fonts</dir>
          <!-- include user and system fonts that will otherwise be lost -->
          <include>${config.environment.etc.fonts.source}/fonts.conf</include>
         </fontconfig>
      '';
    };
  };
}
