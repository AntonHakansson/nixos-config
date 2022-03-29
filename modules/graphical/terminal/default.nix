{ config, lib, pkgs, ... }:

{
  options.asdf.graphical.terminal.enable = lib.mkEnableOption "terminal";

  config = lib.mkIf config.asdf.graphical.terminal.enable {
    home-manager.users.hakanssn = { pkgs, ... }: {
      programs.kitty = let c = config.asdf.graphical.theme.colorscheme.colors;
      in {
        enable = true;
        settings = {
          font_family = "Fira Code";
          font_size = 9;
          disable_ligatures = "cursor";

          background = c.base00;
          foreground = c.base05;
          cursor = c.base05;
          selection_background = c.base05;
          selection_foreground = c.base00;
          url_color = c.base04;
          active_border_color = c.base03;
          inactive_border_color = c.base01;
          active_tab_background = c.base00;
          active_tab_foreground = c.base05;
          inactive_tab_background = c.base01;
          inactive_tab_foreground = c.base04;

          # black
          color0 = c.base01;
          color8 = c.base02;
          # red
          color1 = c.base08;
          color9 = c.base12;
          # green
          color2 = c.base0B;
          color10 = c.base14;
          # yellow
          color3 = c.base09;
          color11 = c.base13;
          # blue
          color4 = c.base0D;
          color12 = c.base16;
          # magenta
          color5 = c.base0E;
          color13 = c.base17;
          # cyan
          color6 = c.base0C;
          color14 = c.base15;
          # white
          color7 = c.base06;
          color15 = c.base07;

          enable_audio_bell = false;
          visual_bell_duration = "0.25";
          remember_window_size = false;
        };
      };
    };
  };
}
