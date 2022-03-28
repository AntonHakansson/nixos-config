{ config, lib, pkgs, ... }:

{
  imports = [ ./audio ./firefox ./mail ./sway ./terminal ./theme ./xdg ];

  options.asdf.graphical.enable = lib.mkOption {
    default = false;
    example = true;
  };

  config = lib.mkIf config.asdf.graphical.enable {
    users.users.hakanssn.extraGroups = [ "input" "video" ];
    asdf = {
      graphical = {
        firefox.enable = lib.mkDefault true;
        audio.enable = lib.mkDefault true;
        sway.enable = lib.mkDefault true;
        terminal.enable = lib.mkDefault true;
        theme.enable = lib.mkDefault true;
        xdg.enable = lib.mkDefault true;
      };
    };

    home-manager.users.hakanssn = { ... }: {
      home.packages = with pkgs; [ brave mpv okular ranger youtube-dl ];
    };
  };
}
