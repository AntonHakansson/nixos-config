{ config, lib, pkgs, ... }:

{
  imports = [
    ./audio
    ./firefox
    ./mail
    ./media
    ./pass
    ./sway
    ./syncthing
    ./terminal
    ./theme
    ./xdg
  ];

  options.asdf.graphical = {
    enable = lib.mkEnableOption "graphical environment";
    laptop = lib.mkEnableOption "laptop configuration";
  };

  config = lib.mkIf config.asdf.graphical.enable {
    users.users.hakanssn.extraGroups = [ "input" "video" ];
    asdf = {
      graphical = {
        audio.enable = lib.mkDefault true;
        firefox.enable = lib.mkDefault true;
        pass.enable = lib.mkDefault true;
        sway.enable = lib.mkDefault true;
        terminal.enable = lib.mkDefault true;
        xdg.enable = lib.mkDefault true;
        media = {
          documents.enable = lib.mkDefault true;
          mpv.enable = lib.mkDefault true;
          recording.enable = lib.mkDefault true;
          spotify.enable = lib.mkDefault true;
        };
      };
    };

    home-manager.users.hakanssn = { ... }: {
      home.packages = with pkgs; [ ranger yt-dlp ];
    };
  };
}
