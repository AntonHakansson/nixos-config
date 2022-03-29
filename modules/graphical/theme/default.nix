{ config, lib, pkgs, ... }:

{
  options.asdf.graphical.theme = {
    enable = lib.mkEnableOption "theme";
    colorscheme = lib.mkOption {
      default = {
        name = "one-dark";
        # https://github.com/Base24/base24/blob/master/styling.md
        colors = {
          base00 = "#282c34"; # Default Background
          base01 = "#353b45"; # Lighter Background (Used for status bars, line number and folding marks)
          base02 = "#3e4451"; # Selection Background
          base03 = "#545862"; # Comments, Invisibles, Line Highlighting
          base04 = "#565c64"; # Dark Foreground (Used for status bars)
          base05 = "#abb2bf"; # Default Foreground, Caret, Delimiters, Operators
          base06 = "#b6bdca"; # Light Foreground (Not often used)
          base07 = "#c8ccd4"; # Light Background (Not often used)
          base08 = "#e06c75"; # Variables, XML Tags, Markup Link Text, Markup Lists, Diff Deleted
          base09 = "#d19a66"; # Integers, Boolean, Constants, XML Attributes, Markup Link Url
          base0A = "#e5c07b"; # Classes, Markup Bold, Search Text Background
          base0B = "#98c379"; # Strings, Inherited Class, Markup Code, Diff Inserted
          base0C = "#56b6c2"; # Support, Regular Expressions, Escape Characters, Markup Quotes
          base0D = "#61afef"; # Functions, Methods, Attribute IDs, Headings
          base0E = "#c678dd"; # Keywords, Storage, Selector, Markup Italic, Diff Changed
          base0F = "#be5046"; # Deprecated
          # base24 extension
          base10 = "#21252b"; # Darker background
          base11 = "#181a1f"; # Darkest background
          base12 = "#ff616e"; # Bright Red
          base13 = "#f0a45d"; # Bright Yellow
          base14 = "#a5e075"; # Bright Green
          base15 = "#4cd1e0"; # Bright Cyan
          base16 = "#4dc4ff"; # Bright Blue
          base17 = "#de73ff"; # Bright purple
        };
      };
    };
  };

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
