{ config, lib, pkgs, ... }:

{
  options.asdf.graphical.theme.enable = lib.mkEnableOption "theme";

  config = lib.mkIf config.asdf.graphical.theme.enable {
    fonts = {
      fontDir.enable = true;
      fontconfig = {
        enable = true;
        defaultFonts = {
          emoji = [ "Noto Color Emoji" ];
          # The Tinos and Amiro fonts overlap with Font Awesome's codepoints, so make sure we give Font Awesome a higher priority.
          monospace = [ "Fira Code" "Font Awesome 5 Free" ];
          sansSerif = [ "Noto Sans" "Font Awesome 5 Free" ];
          serif = [ "Noto Serif" "Font Awesome 5 Free" ];
        };
      };
      fonts = with pkgs; [
        fira-code
        fira-code-symbols
        font-awesome
        noto-fonts
        noto-fonts-cjk
        noto-fonts-emoji
        noto-fonts-extra
      ];
    };

    programs.dconf.enable = true;
    home-manager.users.hakanssn = { pkgs, ... }:
      let flat-remix-theme = "Flat-Remix-GTK-Blue-Dark";
      in {
        home.packages = [ pkgs.vanilla-dmz ];
        dconf.settings."org/gnome/desktop/interface" = {
          gtk-theme = flat-remix-theme;
          icon-theme = flat-remix-theme;
          cursor-theme = "Vanilla-DMZ";
        };
        gtk = {
          enable = true;
          font = {
            package = pkgs.noto-fonts;
            name = "Noto Sans";
            size = 10;
          };
          gtk2.extraConfig = ''
            gtk-cursor-theme-name = "Vanilla-DMZ"
            gtk-cursor-theme-size = 0
          '';
          gtk3.extraConfig = {
            gtk-cursor-theme-name = "Vanilla-DMZ";
            gtk-cursor-theme-size = 0;
          };
          iconTheme = {
            package = pkgs.flat-remix-icon-theme;
            name = flat-remix-theme;
          };
          theme = {
            package = pkgs.flat-remix-gtk;
            name = flat-remix-theme;
          };
        };
        qt = {
          enable = true;
          platformTheme = "gtk";
        };
      };
  };
}
