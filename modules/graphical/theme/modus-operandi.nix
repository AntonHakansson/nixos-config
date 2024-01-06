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
  };
in
{
  config = lib.mkIf
    (config.hakanssn.graphical.theme.enable
      && config.hakanssn.graphical.theme.name == "modus-operandi")
    {
      home-manager.users.hakanssn = { pkgs, ... }:
        let flat-remix-theme = "Flat-Remix-GTK-Blue-Light";
        in {
          dconf.settings."org/gnome/desktop/interface" = {
            gtk-theme = flat-remix-theme;
            icon-theme = flat-remix-theme;
          };
          gtk = {
            iconTheme = {
              package = pkgs.flat-remix-icon-theme;
              name = flat-remix-theme;
            };
            theme = {
              package = pkgs.flat-remix-gtk;
              name = flat-remix-theme;
            };
          };

          wayland.windowManager.sway.config = {
            output = {
              "*" = {
                bg =
                  "${./modus-operandi-wallpaper.png} center ${c.bg-inactive}";
              };
            };
            colors = {
              focused = {
                border = c.fg-dim;
                background = c.bg-dim;
                text = c.fg-main;
                indicator = c.blue;
                childBorder = c.fg-dim;
              };
              focusedInactive = {
                border = c.bg-inactive;
                background = c.bg-main;
                text = c.fg-inactive;
                indicator = c.blue;
                childBorder = c.bg-inactive;
              };
              unfocused = {
                border = c.bg-inactive;
                background = c.bg-main;
                text = c.fg-inactive;
                indicator = c.blue;
                childBorder = c.bg-inactive;
              };
              urgent = {
                border = c.bg-inactive;
                background = c.red-fringe-bg;
                text = c.fg-main;
                indicator = c.blue;
                childBorder = c.bg-inactive;
              };
            };
          };
          wayland.windowManager.hyprland.extraConfig =
            let
              hyprpaper-config = pkgs.writeText "hyprpaper-configuration" ''
                preload = ${./modus-operandi-wallpaper.png}
                wallpaper = HDMI-A-1,${./modus-operandi-wallpaper.png}
              '';
            in
            ''
              # Set Wallpaper
              # exec-once=${pkgs.hyprpaper}/bin/hyprpaper -c ${hyprpaper-config}
            '';

          programs.neovim =
            let
              vim-modus-theme = pkgs.vimUtils.buildVimPlugin {
                name = "modus-theme-vim";
                src = pkgs.fetchFromGitHub {
                  owner = "ishan9299";
                  repo = "modus-theme-vim";
                  rev = "42ee50e89c1869e5bda69fa2cde44e4d72663131";
                  sha256 = "lq7hsO4GExtHZ/xvzpNFli9X8uCioqvymM8rDPP38DU=";
                };
              };
            in
            {
              plugins = [ vim-modus-theme ];
              # extraConfig = "colorscheme modus-operandi";
            };

          programs.kitty = { theme = "Novel"; };

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
        idle_bg = "${c.bg-dim}"
        idle_fg = "${c.fg-dim}"
        info_bg = "${c.bg-active-accent}"
        info_fg = "${c.fg-active}"
        good_bg = "${c.green-fringe-bg}"
        good_fg = "${c.fg-main}"
        warning_bg = "${c.yellow-fringe-bg}"
        warning_fg = "${c.fg-main}"
        critical_bg = "${c.red-fringe-bg}"
        critical_fg = "${c.fg-main}"
        separator_bg = "${c.bg-dim}"
        separator = " "
      '';

      hakanssn.graphical.sway.top-bar = {
        # the active_workspace is the active workspace on non-focused monitor
        extraConfig = ''
          colors {
            background ${c.bg-dim}
            #                  Border      BG                    Text
            focused_workspace  ${c.bg-dim} ${c.bg-active}        ${c.fg-active}
            active_workspace   ${c.bg-dim} ${c.bg-dim}           ${c.fg-dim}
            inactive_workspace ${c.bg-dim} ${c.bg-dim}           ${c.fg-dim}
            urgent_workspace   ${c.bg-dim} ${c.red-fringe-bg}    ${c.fg-dim}
            binding_mode       ${c.bg-dim} ${c.bg-active-accent} ${c.fg-dim}
          }
        '';
      };
    };
}
