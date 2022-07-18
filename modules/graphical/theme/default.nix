{ config, lib, pkgs, ... }:

{
  options.hakanssn.graphical.theme = {
    active = lib.mkOption {
      type = lib.types.nullOr (lib.types.enum [ "onedark" "modus-operandi" ]);
      default = "modus-operandi";
      apply = v:
        let envTheme = builtins.getEnv "THEME";
        in if envTheme != "" then envTheme else v;
      description = ''
        Name of the theme to enable.
        Can be overriden by the THEME environment variable;
      '';
    };
  };

  imports = [ ./onedark.nix ./modus-operandi.nix ];

  config = lib.mkIf (config.hakanssn.graphical.theme.active != null) {
    fonts = {
      fontDir.enable = true;
      fontconfig = { enable = true; };
      fonts = with pkgs; [
        font-awesome
        noto-fonts
        noto-fonts-cjk
        noto-fonts-emoji
        noto-fonts-extra
      ];
    };
    programs.dconf.enable = true;

    hakanssn.graphical.sway.status-configuration.extraConfig = ''
      [icons]
      name = "awesome6"

      [icons.overrides]
      music_next = ""
      music_prev = ""
    '';
  };
}
