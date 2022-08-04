{ config, lib, pkgs, ... }:

# name: Modus Operandi
# author: Protesilaos Stavrou
# license: GNU GPLv3
# blurb: Highly accessible themes made for GNU Emacs, conforming with the highest
# standard for colour contrast between background and foreground values (WCAG AAA)
# upstream: https://gitlab.com/protesilaos/modus-themes

let
  c = rec {
    # Base values
    bg-main = "#ffffff";
    fg-main = "#000000";
    bg-dim = "#f8f8f8";
    fg-dim = "#282828";
    bg-alt = "#f0f0f0";
    fg-alt = "#505050";

    # on/off states, must be combined with themselves and other "active" values.
    bg-active = "#d7d7d7";
    fg-active = "#0a0a0a";
    bg-inactive = "#efefef";
    fg-inactive = "#404148";
    bg-active-accent = "#d0d6ff";

    # alternatives to the base values for cases where we need to avoid confusion
    bg-special-cold = "#dde3f4";
    bg-special-faint-cold = "#f0f1ff";
    fg-special-cold = "#093060";
    bg-special-mild = "#c4ede0";
    bg-special-faint-mild = "#ebf5eb";
    fg-special-mild = "#184034";
    bg-special-warm = "#f0e0d4";
    bg-special-faint-warm = "#fef2ea";
    fg-special-warm = "#5d3026";
    bg-special-calm = "#f8ddea";
    bg-special-faint-calm = "#faeff9";
    fg-special-calm = "#61284f";

    # foregrounds that can be combined with bg-main, bg-dim, bg-alt
    red = "#a60000";
    green = "#005e00";
    yellow = "#813e00";
    blue = "#0031a9";
    magenta = "#721045";
    cyan = "#00538b";

    # backgrounds that must be combined with fg-main
    red-fringe-bg = "#f08290";
    green-fringe-bg = "#62c86a";
    yellow-fringe-bg = "#dbba3f";
    blue-fringe-bg = "#82afff";
    magenta-fringe-bg = "#e0a3ff";
    cyan-fringe-bg = "#2fcddf";

    # bg-header is between bg-active and bg-inactive, so it
    # can be combined with any of the "active" values, plus the
    # "special" and base foreground colors
    bg-header = "#e5e5e5";
    fg-header = "#2a2a2a";

    bg-region = "#bcbcbc";

    # Temporary
    base00 = bg-main; # Default Background
    base01 =
      bg-dim; # Lighter Background (Used for status bars, line number and folding marks)
    base02 = "#3e4451"; # Selection Background
    base03 = "#545862"; # Comments, Invisibles, Line Highlighting
    base04 = "#565c64"; # Dark Foreground (Used for status bars)
    base05 = "#abb2bf"; # Default Foreground, Caret, Delimiters, Operators
    base06 = "#b6bdca"; # Light Foreground (Not often used)
    base07 = "#c8ccd4"; # Light Background (Not often used)
    base08 =
      "#e06c75"; # Variables, XML Tags, Markup Link Text, Markup Lists, Diff Deleted
    base09 =
      "#d19a66"; # Integers, Boolean, Constants, XML Attributes, Markup Link Url
    base0A = "#e5c07b"; # Classes, Markup Bold, Search Text Background
    base0B = "#98c379"; # Strings, Inherited Class, Markup Code, Diff Inserted
    base0C =
      "#56b6c2"; # Support, Regular Expressions, Escape Characters, Markup Quotes
    base0D = "#61afef"; # Functions, Methods, Attribute IDs, Headings
    base0E =
      "#c678dd"; # Keywords, Storage, Selector, Markup Italic, Diff Changed
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
  iosevka = pkgs.iosevka-bin;
  iosevka-aile = pkgs.iosevka-bin.override { variant = "aile"; };
  iosevka-etoile = pkgs.iosevka-bin.override { variant = "etoile"; };
in {
  config = lib.mkIf (config.hakanssn.graphical.theme.active == "modus-operandi") {
    fonts = {
      fontconfig = {
        defaultFonts = {
          emoji = [ "Noto Color Emoji" ];
          monospace = [ "Iosevka" "Font Awesome 6 Free" ];
          sansSerif = [ "Iosevka Aile" "Font Awesome 6 Free" ];
          serif = [ "Iosevka Etoile" "Font Awesome 6 Free" ];
        };
      };
      fonts = [ iosevka iosevka-aile iosevka-etoile ];
    };

    home-manager.users.hakanssn = { pkgs, ... }:
      let flat-remix-theme = "Flat-Remix-GTK-Blue-Light";
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
            package = iosevka-aile;
            name = "Iosevka Aile";
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

        wayland.windowManager.sway.config = {
          fonts = {
            names = config.fonts.fontconfig.defaultFonts.sansSerif;
            size = 9.0;
            style = "Light";
          };
          output = {
            "*" = { bg = "${./modus-operandi-wallpaper.png} fill"; };
          };
          colors = {
            focused = {
              border = c.cyan;
              background = c.bg-main;
              text = c.fg-main;
              indicator = c.blue;
              childBorder = c.cyan;
            };
            focusedInactive = {
              border = c.bg-main;
              background = c.bg-main;
              text = c.fg-main;
              indicator = c.blue;
              childBorder = c.bg-main;
            };
            unfocused = {
              border = c.bg-main;
              background = c.bg-main;
              text = c.fg-main;
              indicator = c.blue;
              childBorder = c.bg-main;
            };
            urgent = {
              border = c.red;
              background = c.bg-main;
              text = c.fg-main;
              indicator = c.blue;
              childBorder = c.bg-main;
            };
          };
        };

        programs.neovim = let
          vim-modus-theme = pkgs.vimUtils.buildVimPlugin {
            name = "modus-theme-vim";
            src = pkgs.fetchFromGitHub {
              owner = "ishan9299";
              repo = "modus-theme-vim";
              rev = "42ee50e89c1869e5bda69fa2cde44e4d72663131";
              sha256 = "lq7hsO4GExtHZ/xvzpNFli9X8uCioqvymM8rDPP38DU=";
            };
          };
        in {
          plugins = [ vim-modus-theme ];
          # extraConfig = "colorscheme modus-operandi";
        };

        programs.kitty = {
          theme = "Modus Operandi";
          settings = {
            font_family = "Iosevka";
            font_size = 10;
            disable_ligatures = "cursor";
          };
        };

        programs.zathura.options = {
          default-bg = c.bg-main;
          default-fg = c.fg-main;
          statusbar-bg = c.bg-dim;
          statusbar-fg = c.fg-dim;
          inputbar-bg = c.bg-alt;
          inputbar-fg = c.fg-alt;
          notification-bg = c.bg-active-accent;
          notification-fg = c.fg-main;
          notification-error-bg = c.red-fringe-bg;
          notification-error-fg = c.fg-main;
          notification-warning-bg = c.yellow-fringe-bg;
          notification-warning-fg = c.fg-main;
          recolor-lightcolor = c.fg-main;
          recolor-darkcolor = c.bg-main;
        };
      };

    # Available options: https://github.com/greshake/i3status-rust/blob/master/doc/themes.md#available-theme-overrides
    hakanssn.graphical.sway.status-configuration.extraConfig = ''
      [theme]
      name = "plain"

      [theme.overrides]
      idle_bg = "${c.bg-main}"
      idle_fg = "${c.fg-main}"
      info_bg = "${c.bg-active-accent}"
      info_fg = "${c.fg-main}"
      good_bg = "${c.green-fringe-bg}"
      good_fg = "${c.fg-main}"
      warning_bg = "${c.yellow-fringe-bg}"
      warning_fg = "${c.fg-main}"
      critical_bg = "${c.red-fringe-bg}"
      critical_fg = "${c.fg-main}"
      separator_bg = "${c.bg-main}"
      separator = " "
    '';

    hakanssn.graphical.sway.top-bar = {
      fonts = {
        names = config.fonts.fontconfig.defaultFonts.sansSerif;
        size = 9.0;
        style = "Light";
      };
      # the active_workspace is the active workspace on non-focused monitor
      extraConfig = ''
        colors {
          background ${c.bg-main}
          #                   Border          BG                    Text
          focused_workspace  ${c.bg-active}   ${c.bg-active}        ${c.fg-main}
          active_workspace   ${c.bg-inactive} ${c.bg-inactive}      ${c.fg-inactive}
          inactive_workspace ${c.bg-inactive} ${c.bg-inactive}      ${c.fg-inactive}
          urgent_workspace   ${c.bg-active}   ${c.red-fringe-bg}    ${c.bg-main}
          binding_mode       ${c.bg-main}     ${c.bg-active-accent} ${c.fg-active}
        }
      '';
    };
  };
}
