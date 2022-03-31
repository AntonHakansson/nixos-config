{ config, lib, pkgs, ... }:

{
  config = lib.mkIf config.asdf.graphical.media.documents.enable {
    home-manager.users.hakanssn = { ... }: {
      home.packages = with pkgs; [ zathura okular ];
      xdg.configFile."zathura/zathurarc".text =
        let c = config.asdf.graphical.theme.colorscheme.colors;
        in ''
          ## General
          set window-title-home-tilde 1
          set statusbar-home-tilde 1

          set selection-clipboard clipboard

          set statusbar-h-padding 0
          set statusbar-v-padding 0
          set page-padding 1

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

          ## Theme
          set font "Fira Code"
          set default-bg "${c.base00}"
          set default-fg "${c.base01}"

          set statusbar-bg "${c.base04}"
          set statusbar-fg "${c.base02}"

          set inputbar-bg "${c.base00}"
          set inputbar-fg "${c.base07}"

          set notification-bg "${c.base00}"
          set notification-fg "${c.base07}"

          set notification-error-bg "${c.base00}"
          set notification-error-fg "${c.base08}"

          set notification-warning-bg "${c.base00}"
          set notification-warning-fg "${c.base09}"

          set highlight-color          "${c.base0A}"
          set highlight-active-color   "${c.base0D}"

          set completion-bg "${c.base01}"
          set completion-fg "${c.base0D}"

          set completion-highlight-bg "${c.base0D}"
          set completion-highlight-fg "${c.base07}"

          set recolor-lightcolor "${c.base00}"
          set recolor-darkcolor "${c.base06}"
        '';
    };
  };
}
