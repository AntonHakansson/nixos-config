{ config, lib, pkgs, ... }:

{
  imports = [
    ./audio
    ./firefox
    ./games
    ./hyprland
    ./mail
    ./media
    ./pass
    ./plasma
    ./sway
    ./syncthing
    ./terminal
    ./theme
    ./xdg
  ];

  options.hakanssn.graphical = {
    enable = lib.mkEnableOption "graphical environment";
    laptop = lib.mkEnableOption "laptop configuration";
  };

  config = lib.mkIf config.hakanssn.graphical.enable {
    users.users.hakanssn.extraGroups = [ "input" "video" ];
    hakanssn = {
      graphical = {
        audio.enable = lib.mkDefault true;
        firefox.enable = lib.mkDefault true;
        mail.enable = lib.mkDefault true;
        media = {
          documents.enable = lib.mkDefault true;
          mpv.enable = lib.mkDefault true;
          recording.enable = lib.mkDefault false;
        };
        pass.enable = lib.mkDefault true;
        sway.enable = lib.mkDefault false;
        hyprland.enable = lib.mkDefault false;
        plasma.enable = lib.mkDefault false;
        terminal.enable = lib.mkDefault true;
        theme.enable = lib.mkDefault true;
        xdg.enable = lib.mkDefault true;
      };
    };

    home-manager.users.hakanssn = { ... }: {
      home.packages = with pkgs; [ yt-dlp ];
    };
  };
}
