{ config, lib, pkgs, ... }:

{
  options.hakanssn.graphical.theme = {
    enable = lib.mkEnableOption "hakanssn themes";
    name = lib.mkOption {
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
    enableAutoSwitch = lib.mkOption {
      default = config.system.autoUpgrade.enable;
      description = "Switch to 'onedark' after 18:00";
    };
  };

  imports = [ ./onedark.nix ./modus-operandi.nix ];

  config = lib.mkIf (config.hakanssn.graphical.theme.enable) (lib.mkMerge [
    # Common Config
    (let
      iosevka = pkgs.iosevka-bin;
      iosevka-aile = pkgs.iosevka-bin.override { variant = "aile"; };
      iosevka-etoile = pkgs.iosevka-bin.override { variant = "etoile"; };
    in {
      fonts = {
        fontDir.enable = true;
        fontconfig = {
          enable = true;
          defaultFonts = {
            emoji = [ "Noto Color Emoji" ];
            monospace = [ "Iosevka" "Font Awesome 6 Free" ];
            sansSerif = [ "Iosevka Aile" "Font Awesome 6 Free" ];
            serif = [ "Iosevka Etoile" "Font Awesome 6 Free" ];
          };
        };
        fonts = with pkgs; [
          iosevka
          iosevka-aile
          iosevka-etoile
          font-awesome
          noto-fonts
          noto-fonts-cjk
          noto-fonts-emoji
          noto-fonts-extra
        ];
      };
      home-manager.users.hakanssn = { pkgs, ... }: {
        home.packages = [ pkgs.vanilla-dmz ];
        dconf = {
          enable = true;
          settings."org/gnome/desktop/interface" = {
            cursor-theme = "Vanilla-DMZ";
          };
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
        };

        programs.kitty = {
          settings = {
            font_family = "Iosevka";
            font_size = 10;
            disable_ligatures = "cursor";
          };
        };
      };

      hakanssn.graphical.sway.status-configuration.extraConfig = ''
        [icons]
        name = "awesome6"

        [icons.overrides]
        music_next = ""
        music_prev = ""
      '';

      hakanssn.graphical.sway.top-bar = {
        fonts = {
          names = config.fonts.fontconfig.defaultFonts.sansSerif;
          size = 9.0;
          style = "Light";
        };
      };
    })

    (lib.mkIf (config.hakanssn.graphical.theme.enableAutoSwitch) {
      home-manager.users.hakanssn = { ... }: {
        systemd.user = {
          services.theme-switch = {
            Unit = { Description = "Service that switches to dark theme"; };
            Service = {
              Type = "oneshot";
              ExecStart = "${
                  (pkgs.writeShellScriptBin "theme-switch" ''
                    doas env THEME="onedark" nixos-rebuild switch --flake github:AntonHakansson/nixos-config --impure
                  '')
                }/bin/theme-switch";
            };
          };
          timers.theme-switch = {
            Unit = {
              Description = "Timer that switches theme after 18:00";
              PartOf = [ "theme-switch.service" ];
            };
            Timer = { OnCalendar = "*-*-* 18:00:00"; };
            Install = { WantedBy = [ "default.target" ]; };
          };
        };
      };
    })
  ]);
}
