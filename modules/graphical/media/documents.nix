{ config, lib, pkgs, ... }:

{
  options.hakanssn.graphical.media = {
    documents.enable = lib.mkEnableOption "document readers";
  };

  config = lib.mkIf config.hakanssn.graphical.media.documents.enable {
    hakanssn.core.zfs.homeDataLinks = [ ".config/obsidian" ];
    hakanssn.core.nix.unfreePackages = [ "obsidian" ];

    home-manager.users.hakanssn = { ... }: {
      home.packages = with pkgs; [ okular obsidian ];
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
