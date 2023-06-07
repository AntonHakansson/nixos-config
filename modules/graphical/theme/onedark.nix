{ config, lib, pkgs, ... }:

let
  c = {
    base00 = "#282c34"; # Default Background
    base01 =
      "#353b45"; # Lighter Background (Used for status bars, line number and folding marks)
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
in
{
  config = lib.mkIf
    (config.hakanssn.graphical.theme.enable
      && config.hakanssn.graphical.theme.name == "onedark")
    {
      home-manager.users.hakanssn = { pkgs, ... }:
        let flat-remix-theme = "Flat-Remix-GTK-Blue-Dark";
        in {
          dconf.settings."org/gnome/desktop/interface" = {
            gtk-theme = flat-remix-theme;
            icon-theme = flat-remix-theme;
          };
          gtk = {
            enable = true;
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
            colors = {
              focused = {
                border = c.base05;
                background = c.base0D;
                text = c.base00;
                indicator = c.base0D;
                childBorder = c.base0D;
              };
              focusedInactive = {
                border = c.base01;
                background = c.base01;
                text = c.base05;
                indicator = c.base03;
                childBorder = c.base01;
              };
              unfocused = {
                border = c.base01;
                background = c.base00;
                text = c.base05;
                indicator = c.base01;
                childBorder = c.base01;
              };
              urgent = {
                border = c.base08;
                background = c.base08;
                text = c.base00;
                indicator = c.base08;
                childBorder = c.base08;
              };
            };
          };

          programs.neovim = {
            plugins = with pkgs.vimPlugins; [ onedark-nvim ];
            extraConfig = "colorscheme onedark";
          };

          programs.kitty = { theme = "Doom One"; };

          programs.zathura.options = {
            default-bg = c.base00;
            default-fg = c.base01;
            statusbar-bg = c.base04;
            statusbar-fg = c.base02;
            inputbar-bg = c.base00;
            inputbar-fg = c.base07;
            notification-bg = c.base00;
            notification-fg = c.base07;
            notification-error-bg = c.base00;
            notification-error-fg = c.base08;
            notification-warning-bg = c.base00;
            notification-warning-fg = c.base09;
            highlight-color = c.base0A;
            highlight-active-color = c.base0D;
            completion-bg = c.base01;
            completion-fg = c.base0D;
            completion-highlight-bg = c.base0D;
            completion-highlight-fg = c.base07;
            recolor-lightcolor = c.base00;
            recolor-darkcolor = c.base06;
          };
        };

      hakanssn.graphical.sway.status-configuration.extraConfig = ''
        [theme]
        name = "dracula"

        [theme.overrides]
        idle_bg="${c.base00}"
        idle_fg="${c.base05}"
        separator=" "
      '';

      hakanssn.graphical.sway.top-bar = {
        extraConfig = ''
          colors {
            background ${c.base00}
            separator  ${c.base01}
            statusline ${c.base04}
            #                   Border      BG          Text
            focused_workspace   ${c.base05} ${c.base0D} ${c.base00}
            active_workspace    ${c.base05} ${c.base03} ${c.base00}
            inactive_workspace  ${c.base03} ${c.base01} ${c.base05}
            urgent_workspace    ${c.base08} ${c.base08} ${c.base00}
            binding_mode        ${c.base00} ${c.base0A} ${c.base00}
          }
        '';
      };
    };
}
