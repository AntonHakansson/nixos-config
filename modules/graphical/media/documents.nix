{ config, lib, pkgs, ... }:

{
  config = lib.mkIf config.asdf.graphical.media.documents.enable {
    home-manager.users.hakanssn = { ... }: {
      home.packages = with pkgs; [ zathura okular ];
      xdg.configFile."zathura".text = ''
        set statusbar-h-padding 0
        set statusbar-v-padding 0
        set page-padding 1

        set window-title-home-tilde 1
        set statusbar-home-tilde 1

        set selection-clipboard clipboard

        set font "Fira Code"
        set default-bg "#282c34"
        set default-fg "#bbc2cf"
        set statusbar-bg "#1E2029"
        set statusbar-fg "#bbc2cf"
        set inputbar-bg "#282c34"
        set inputbar-fg "#bbc2cf"
        set notification-bg "#282c34"
        set notification-fg "#bbc2cf"
        set notification-warning-bg "#ff6c6b"
        set notification-warning-fg "#1E2029"
        set notification-error-bg "#ff6c6b"
        set notification-error-fg "#1E2029"
        set completion-bg "#1E2029"
        set completion-fg "#bbc2cf"
        set completion-group-bg "#1E2029"
        set completion-group-fg "#51afef"
        set completion-highlight-bg "#2257a0"
        set completion-highlight-fg "#bbc2cf"
        set index-bg "#282c34"
        set index-fg "#bbc2cf"
        set index-active-bg "#2257a0"
        set index-active-fg "#bbc2cf"

        set recolor-lightcolor "#282c34"
        set recolor-darkcolor "#bbc2cf"
        set recolor-reverse-video "true"

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
      xdg.configFile."zathura/zathurarc".text =
    };
  };
}
