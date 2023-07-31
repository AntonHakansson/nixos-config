{ config, lib, pkgs, ... }:

let
  launcher = import ./launcher.nix {
    inherit pkgs;
    stdenv = pkgs.stdenv;
  };
  status-configuration =
    import ./status-configuration.nix { inherit pkgs lib config; };
  sway-which-key = pkgs.writeShellApplication {
    name = "sway-which-key";
    runtimeInputs = with pkgs; [ skim gnugrep ];
    text = ''
      # Utility to fuzzy-search sway keybindings
      sk --reverse -c 'cat .config/sway/config | grep bindsym | sed "s/^[[:blank:]]*bindsym//"'
    '';
  };
  pactl-cycle-output = pkgs.writeShellApplication {
    name = "pactl-cycle-output";
    runtimeInputs = with pkgs; [ gnugrep gawk pulseaudio ];
    text = ''
      default_sink=$(pactl info | grep "Default Sink:" | cut '-d ' -f3)
      sinks=$(pactl list short sinks | cut -f2)

      # for wrap-around
      sinks="$sinks
      $sinks"

      next_sink=$(echo "$sinks" | awk "/$default_sink/{getline x;print x;exit;}")

      pactl set-default-sink "$next_sink"
      pactl list short sink-inputs | \
        cut -f1 | \
        xargs -I{} pactl move-sink-input {} "$next_sink"
    '';
  };
  swaylock-cmd = "${pkgs.swaylock-fancy}/bin/swaylock-fancy";
in
{
  options.hakanssn.graphical.sway = {
    enable = lib.mkEnableOption "swaywm";
    top-bar = lib.mkOption {
      default = { };
      type = lib.types.attrs;
    };
    status-configuration.extraConfig = lib.mkOption {
      default = "";
      type = lib.types.lines;
    };
  };

  config = lib.mkIf config.hakanssn.graphical.sway.enable {
    services.dbus.packages = with pkgs; [ dconf ];
    security.pam.services.swaylock = { };
    xdg.portal = {
      enable = true;
      extraPortals =
        [ pkgs.xdg-desktop-portal-gtk pkgs.xdg-desktop-portal-wlr ];
    };
    home-manager.users.hakanssn = { pkgs, ... }: {
      home.packages = with pkgs; [ wf-recorder wl-clipboard ];
      programs = {
        mako = {
          enable = true;
        };
        zsh.loginExtra = ''
          if [[ -z "$DISPLAY" ]] && [[ $(tty) = "/dev/tty1" ]]; then
              exec sway
          fi
        '';
      };

      # Wayland equivalent autorandr
      services.kanshi = { enable = true; };

      services.swayidle = {
        enable = true;
        timeouts = [
          {
            timeout = 300;
            command = "${swaylock-cmd}";
          }
          {
            timeout = 150;
            command = ''${pkgs.sway}/bin/swaymsg "output * dpms off"'';
            resumeCommand = ''${pkgs.sway}/bin/swaymsg "output * dpms on"'';
          }
        ];
        events = [{
          event = "before-sleep";
          command = "${swaylock-cmd}";
        }];
      };

      wayland.windowManager.sway = {
        enable = true;
        config = rec {
          modifier = "Mod4";
          terminal = "${pkgs.kitty}/bin/kitty";
          menu = "${terminal} --class launcher -e ${launcher}/bin/launcher";
          bars = [
            ({
              position = "top";
              statusCommand = "env I3RS_GITHUB_TOKEN=$(<${
                  config.age.secrets."passwords/services/github-notification-token".path
                }) ${pkgs.i3status-rust}/bin/i3status-rs ${status-configuration}";
            } // config.hakanssn.graphical.sway.top-bar)
          ];
          window.commands = [
            {
              command = "floating enable";
              criteria = { app_id = "launcher"; };
            }
            {
              command = "floating enable";
              criteria = { app_id = "sway-which-key"; };
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
            "${modifier}+c" = "exec ${swaylock-cmd}";

            ## Window
            "${modifier}+Shift+t" = "sticky toggle"; # on top

            ## Bar
            "${modifier}+b" = "exec swaymsg bar mode toggle";

            ## Notifications
            "${modifier}+n" = "exec ${pkgs.mako}/bin/makoctl dismiss";
            "${modifier}+Shift+n" = "exec ${pkgs.mako}/bin/makoctl invoke";

            ## Programs
            "${modifier}+Slash" =
              "exec ${terminal} --class sway-which-key -e ${sway-which-key}/bin/sway-which-key";

            ## Media keys
            "${modifier}+bracketleft" =
              "exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ -5%";
            "${modifier}+bracketright" =
              "exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ +5%";
            "${modifier}+p" =
              "exec ${pactl-cycle-output}/bin/pactl-cycle-output";
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
          no_focus [title="Microsoft Teams Notification"]

          default_border pixel 1

          workspace 1
          exec ${config.hakanssn.graphical.firefox.package}/bin/firefox
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
    age.secrets."passwords/services/github-notification-token" = {
      file = ../../../secrets/passwords/services/github-notification-token.age;
      owner = "hakanssn";
    };
  };
}
