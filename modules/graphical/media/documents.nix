{ config, lib, pkgs, ... }:

{
  config = lib.mkIf config.hakanssn.graphical.media.documents.enable {
    home-manager.users.hakanssn = { ... }: {
      home.packages = with pkgs; [ okular ];
      programs.zathura = {
        enable = true;
        options = {
          window-title-home-tilde = true;
          statusbar-home-tilde = true;
          selection-clipboard = "clipboard";
          statusbar-h-padding = 0;
          statusbar-v-padding = 0;
          page-padding = 1;
        };
        extraConfig = ''
          ## Keybindings
          map u scroll half-up
          map d scroll half-down
          map D toggle_page_mode
          map r reload
          map R rotate
          map K zoom in
          map J zoom out
          map i recolor
          map p print
        '';
      };
    };
  };
}
