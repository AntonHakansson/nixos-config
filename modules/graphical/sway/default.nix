{ config, lib, pkgs, ... }:

let
  launcher = import ./launcher.nix {
    inherit pkgs;
    stdenv = pkgs.stdenv;
  };
  status-configuration =
    import ./status-configuration.nix { inherit pkgs lib config; };
  c = config.asdf.graphical.theme.colorscheme.colors;
in {
  options.asdf.graphical.sway.enable = lib.mkEnableOption "swaywm";

  config = lib.mkIf config.asdf.graphical.sway.enable {
    services.dbus.packages = with pkgs; [ dconf ];
    security.pam.services.swaylock = { };
    xdg.portal = {
      enable = true;
      gtkUsePortal = true;
      extraPortals =
        [ pkgs.xdg-desktop-portal-gtk pkgs.xdg-desktop-portal-wlr ];
    };
    home-manager.users.hakanssn = { pkgs, ... }: {
      home.packages = with pkgs; [ wf-recorder wl-clipboard ];
      programs = {
        mako = {
          enable = true;
          font = "Fira Code Normal 9";
        };
        zsh.loginExtra = ''
          if [[ -z "$DISPLAY" ]] && [[ $(tty) = "/dev/tty1" ]]; then
              exec sway
          fi
        '';
      };

      # Wayland equivalent autorandr
      services.kanshi = { enable = true; };

      services.wlsunset = {
        enable = true;
        latitude = "57.7";
        longitude = "11.9";
      };

      wayland.windowManager.sway = {
        enable = true;
        config = rec {
          modifier = "Mod4";
          terminal = "${pkgs.kitty}/bin/kitty";
          menu = "${terminal} --class launcher -e ${launcher}/bin/launcher";
          fonts = {
            names = [ "Fira Code" ];
            size = 9.0;
            style = "Normal";
          };
          bars = [{
            fonts = {
              names = [ "Fira Code" ];
              size = 9.0;
              style = "Normal";
            };
            position = "top";
            statusCommand =
              "${pkgs.i3status-rust}/bin/i3status-rs ${status-configuration}";
            extraConfig = ''
              status_padding 0
              icon_theme Arc
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
          }];
          startup = [{
            command =
              "${pkgs.swayidle}/bin/swayidle -w timeout 300 '${pkgs.swaylock}/bin/swaylock -f -c 000000' timeout 150 '${pkgs.sway}/bin/swaymsg \"output * dpms off\"' resume '${pkgs.sway}/bin/swaymsg \"output * dpms on\"' before-sleep '${pkgs.swaylock}/bin/swaylock -f -c 000000'";
          }];
          window.commands = [
            {
              command = "floating enable";
              criteria = { app_id = "launcher"; };
            }
            {
              command = "floating enable";
              criteria = {
                title = "Quick Format Citation";
                class = "Zotero";
              };
            }
          ];
          input = {
            "type:keyboard" = {
              xkb_layout = "us";
              xkb_variant = "altgr-intl";
            };
          };
          keybindings = lib.mkOptionDefault {
            ## Power
            "${modifier}+Shift+r" = "reload";
            "${modifier}+q" = "kill";
            "${modifier}+c" = "exec ${pkgs.swaylock}/bin/swaylock -f -c 000000";

            ## Window
            "${modifier}+Shift+t" = "sticky toggle"; # on top

            ## Bar
            "${modifier}+b" = "exec swaymsg bar mode toggle";
            "${modifier}+n" =
              "exec ${pkgs.mako}/bin/makoctl invoke"; # Invoke default action on top notification.

            ## Media keys
            "XF86AudioRaiseVolume" =
              "exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ +5%";
            "XF86AudioLowerVolume" =
              "exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ -5%";
            "XF86AudioMute" =
              "exec ${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle";
            "XF86AudioMicMute" =
              "exec ${pkgs.pulseaudio}/bin/pactl set-source-mute @DEFAULT_SOURCE@ toggle";
            "XF86MonBrightnessDown" =
              "exec ${pkgs.brightnessctl}/bin/brightnessctl set 5%-";
            "XF86MonBrightnessUp" =
              "exec ${pkgs.brightnessctl}/bin/brightnessctl set +5%";

            ## Unset
            "${modifier}+Shift+q" = "nop Unset default kill";
          };
        };
        extraConfig = ''
          #                       Border      BG          Text        Ind         Child Border
          client.focused          ${c.base05} ${c.base0D} ${c.base00} ${c.base0D} ${c.base0D}
          client.focused_inactive ${c.base01} ${c.base01} ${c.base05} ${c.base03} ${c.base01}
          client.unfocused        ${c.base01} ${c.base00} ${c.base05} ${c.base01} ${c.base01}
          client.urgent           ${c.base08} ${c.base08} ${c.base00} ${c.base08} ${c.base08}

          no_focus [title="Microsoft Teams Notification"]

          default_border pixel

          workspace 1
          exec ${config.asdf.graphical.firefox.package}/bin/firefox
        '';
        extraSessionCommands = ''
          export XDG_SESSION_TYPE=wayland
          export XDG_CURRENT_DESKTOP=sway
          export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
          export QT_AUTO_SCREEN_SCALE_FACTOR=0
          export QT_SCALE_FACTOR=1
          export GDK_SCALE=1
          export GDK_DPI_SCALE=1
          export MOZ_ENABLE_WAYLAND=1
          export _JAVA_AWT_WM_NONREPARENTING=1
        '';
        wrapperFeatures = {
          base = true;
          gtk = true;
        };
        xwayland = true;
      };
    };
  };
}
