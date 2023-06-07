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
        Can be overriden by the THEME environment variable if `--impure` flag is present;
      '';
    };
    autoSwitchTheme = lib.mkOption {
      default = true;
      description = "When autoupgrading, switch to dark theme after 18:00";
    };
  };

  imports = [ ./onedark.nix ./modus-operandi.nix ];

  config = lib.mkIf (config.hakanssn.graphical.theme.enable) (lib.mkMerge [
    # Common Config
    (
      let
        iosevka = pkgs.iosevka-bin;
        iosevka-aile = pkgs.iosevka-bin.override { variant = "aile"; };
        iosevka-etoile = pkgs.iosevka-bin.override { variant = "etoile"; };
      in
      {
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
        programs.dconf.enable = true;
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
      }
    )

    (lib.mkIf (config.hakanssn.graphical.theme.autoSwitchTheme) {
      # We replace the default autoUpgrade systemd service with a custom one
      system.autoUpgrade.enable = false;

      systemd.services.nixos-upgrade-and-set-theme = {
        description = "NixOS 'onedark' theme";

        restartIfChanged = false;
        unitConfig.X-StopOnRemoval = false;

        serviceConfig.Type = "oneshot";

        environment = config.nix.envVars // {
          inherit (config.environment.sessionVariables) NIX_PATH;
          HOME = "/root";
        } // config.networking.proxy.envVars;

        path = with pkgs; [
          coreutils
          gnutar
          xz.bin
          gzip
          gitMinimal
          config.nix.package.out
          config.programs.ssh.package
        ];

        script =
          let
            nixos-rebuild =
              "${config.system.build.nixos-rebuild}/bin/nixos-rebuild";
          in
          ''
            theme=""
            currenttime=$(date +%H:%M)
            if [[ "$currenttime" > "6:00" ]] || [[ "$currenttime" < "18:00" ]]; then
              theme="modus-operandi"
            else
              theme="onedark"
            fi
            env THEME="$theme" ${nixos-rebuild} switch --flake github:AntonHakansson/nixos-config --impure
          '';

        startAt = config.system.autoUpgrade.dates;

        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
      };

      systemd.timers.nixos-upgrade-and-set-theme = {
        timerConfig = {
          RandomizedDelaySec = config.system.autoUpgrade.randomizedDelaySec;
          Persistent = true;
        };
      };
    })
  ]);
}
