{ config, lib, pkgs, ... }:

{
  options.hakanssn.graphical.hyprland = {
    enable = lib.mkEnableOption "hyprlandwm";
    top-bar = lib.mkOption {
      default = { };
      type = lib.types.attrs;
    };
    status-configuration.extraConfig = lib.mkOption {
      default = "";
      type = lib.types.lines;
    };
  };

  config = lib.mkIf config.hakanssn.graphical.hyprland.enable {
    services.dbus.packages = with pkgs; [ dconf ];
    xdg.portal = {
      enable = true;
      extraPortals =
        with pkgs; [ xdg-desktop-portal-gtk xdg-desktop-portal-hyprland ];
    };

    home-manager.users.hakanssn = { pkgs, ... }: {
      home.packages = with pkgs; [ wf-recorder wl-clipboard ];
      services = {
        mako = {
          enable = true;
          font = "Fira Code Normal 9";
        };
      };
      wayland.windowManager.hyprland = {
        enable = true;
        nvidiaPatches = true;
        extraConfig = ''
            # See https://wiki.hyprland.org/Configuring/Monitors/
            monitor=,preferred,auto,1

            # See https://wiki.hyprland.org/Configuring/Keywords/ for more
            # For all categories, see https://wiki.hyprland.org/Configuring/Variables/

          input {
                kb_layout = us
                kb_variant = altgr-intl
                kb_model =
                kb_options = ctrl:nocaps
                kb_rules =

                follow_mouse = 1

                touchpad {
                    natural_scroll = no
                }

                sensitivity = 0 # -1.0 - 1.0, 0 means no modification.
                accel_profile = adaptive
            }

            general {
                # See https://wiki.hyprland.org/Configuring/Variables/
                gaps_in = 5
                gaps_out = 6
                border_size = 0
                col.active_border = rgb(505050)
                col.inactive_border = rgb(efefef)

                layout = master
            }

            # background color
            exec-once = ${pkgs.swaybg}/bin/swaybg -c "##fbf7f0"

            decoration {
                # See https://wiki.hyprland.org/Configuring/Variables/
                rounding = 0
                blur = no

                drop_shadow = yes
                shadow_range = 4
                shadow_render_power = 3
                col.shadow = rgba(1a1a1aee)

                dim_inactive = true
                dim_strength = 0.1
            }

            animations {
                # See https://wiki.hyprland.org/Configuring/Animations/
                enabled = yes
                animation=workspaces, 0, 8, default
            }

            master {
                # See https://wiki.hyprland.org/Configuring/Master-Layout/
            }

            gestures {
                # See https://wiki.hyprland.org/Configuring/Variables/
                workspace_swipe = off
            }

            misc {
                 disable_hyprland_logo = true
                 disable_splash_rendering = true
                 enable_swallow = true
                 swallow_regex = ^(kitty)$
            }

            # Window Rules
            ## See https://wiki.hyprland.org/Configuring/Window-Rules/ for more
            windowrule = float, ^(launcher)$
            windowrule = float, ^(kitty)$

          	windowrule = float, title:^(Volume Control)$
           	windowrule = size 33% 480, title:^(Volume Control)$
           	windowrule = move 66% 24, title:^(Volume Control)$

            windowrule = float, title:^(Picture-in-Picture)$|^(Firefox — Sharing Indicator)$|^(About Mozilla Firefox)$
            windowrule = move 0 0, title:^(Firefox — Sharing Indicator)$
            windowrule = idleinhibit fullscreen, firefox

            windowrule = float, ^(emacs)$

            windowrule = float, ^(mpv)$
            windowrule = center, ^(mpv)$
            windowrule = size 1080 600, ^(mpv)$
            windowrule = idleinhibit focus, mpv

            # Status Bar
            exec-once = waybar
            bind = SUPER, b, exec, ${pkgs.killall}/bin/killall -SIGUSR1 .waybar-wrapped

            # Keybindings
            ## See https://wiki.hyprland.org/Configuring/Binds/
            bind = SUPER, return, exec, kitty --single-instance
            bind = SUPER, Q, killactive,
            bind = SUPER SHIFT, E, exec, hyprctl kill
            bind = SUPER SHIFT, M, exit,
            bind = SUPER, F, fullscreen,
            bind = SUPER, V, togglefloating,
            bind = SUPER, T, pin,
            bind = SUPER, D, exec, ${pkgs.kitty}/bin/kitty --class launcher -e ${./launcher.zsh}
            bind = SUPER, E, exec, emacs -n

            # Move focus
            bind = SUPER, h, movefocus, l
            bind = SUPER, l, movefocus, r
            bind = SUPER, k, layoutmsg, cycleprev
            bind = SUPER, j, layoutmsg, cyclenext
            bind = SUPER, Tab, cyclenext,

            # Move windows with super shift + hjkl
            bind = SUPER SHIFT, h, movewindow, l
            bind = SUPER SHIFT, l, movewindow, r
            bind = SUPER SHIFT, k, layoutmsg, swapprev
            bind = SUPER SHIFT, j, layoutmsg, swapnext
            bind = SUPER, space, layoutmsg, swapwithmaster

            # Switch workspaces with super + [0-9]
            bind = SUPER, 1, workspace, 1
            bind = SUPER, 2, workspace, 2
            bind = SUPER, 3, workspace, 3
            bind = SUPER, 4, workspace, 4
            bind = SUPER, 5, workspace, 5
            bind = SUPER, 6, workspace, 6
            bind = SUPER, 7, workspace, 7
            bind = SUPER, 8, workspace, 8
            bind = SUPER, 9, workspace, 9
            bind = SUPER, 0, workspace, 10

            # Move active window to a workspace with super + shift + [0-9]
            bind = SUPER SHIFT, 1, movetoworkspace, 1
            bind = SUPER SHIFT, 2, movetoworkspace, 2
            bind = SUPER SHIFT, 3, movetoworkspace, 3
            bind = SUPER SHIFT, 4, movetoworkspace, 4
            bind = SUPER SHIFT, 5, movetoworkspace, 5
            bind = SUPER SHIFT, 6, movetoworkspace, 6
            bind = SUPER SHIFT, 7, movetoworkspace, 7
            bind = SUPER SHIFT, 8, movetoworkspace, 8
            bind = SUPER SHIFT, 9, movetoworkspace, 9
            bind = SUPER SHIFT, 0, movetoworkspace, 10

            # Scratchpad
            bind = SUPER, MINUS, togglespecialworkspace,
            bind = SUPER SHIFT, MINUS, movetoworkspace, special

            # Scroll through existing workspaces with super + scroll
            bind = SUPER, mouse_down, workspace, e+1
            bind = SUPER, mouse_up, workspace, e-1

            # Move/resize windows with super + LMB/RMB and dragging
            bindm = SUPER, mouse:272, movewindow
            bindm = SUPER, mouse:273, resizewindow

            # Media Keys
            binde =, XF86AudioRaiseVolume, exec, ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ +5%
            bindl =, XF86AudioLowerVolume, exec, ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ -5%
            bind  =, XF86AudioMute,        exec, ${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle
            bind  =, XF86AudioMicMute,     exec, ${pkgs.pulseaudio}/bin/pactl set-source-mute @DEFAULT_SOURCE@ toggle
            bind  =, XF86MonBrightnessDown,exec, ${pkgs.brightnessctl}/bin/brightnessctl set 5%-"
            bind  =, XF86MonBrightnessUp,  exec, ${pkgs.brightnessctl}/bin/brightnessctl set 5%+"

            # Notifications
            bind = SUPER,       N, exec, ${pkgs.mako}/bin/makoctl dismiss
            bind = SUPER SHIFT, N, exec, ${pkgs.mako}/bin/makoctl invoke;
        '';
      };
      programs.waybar = {
        enable = true;
        package = pkgs.waybar.overrideAttrs (oldAttrs: {
          mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" ];
        });
        settings = [{
          position = "top";
          margin = "6 6 0 6";
          modules-left = [ "wlr/workspaces" ];
          modules-center = [ "clock" ];
          modules-right = [
            "custom/media"
            "network"
            "pulseaudio"
            "battery"
            "tray"
          ];
          "clock" = {
            format = "{:%a %d %b    %H:%M}";
            interval = 60;
            tooltip-format = "{:%Y-%m-%d}";
            on-click = "emacs -n -e \"(progn (org-agenda :arg \\\"g\\\") (delete-other-windows))\"";
          };
          "custom/media" = {
            "format" = "{icon} {}";
            "return-type" = "json";
            "format-icons" = {
              "Playing" = " ";
              "Paused" = " ";
            };
            "max-length" = 70;
            "exec" = ''
              ${pkgs.playerctl}/bin/playerctl -a metadata --format '{"text": "{{trunc(artist, 10)}} - {{markup_escape(title)}}", "tooltip": "{{playerName}} : {{markup_escape(title)}}", "alt": "{{status}}", "class": "{{status}}"}' -F
            '';
            "on-click" = "${pkgs.playerctl}/bin/playerctl play-pause";
          };
          "network" = {
            format = "";
          };
          "pulseaudio" = {
            format = "{icon}";
            format-muted = "<span color=\"#4a4a4a\"></span>";
            format-icons = [ "" "" "" ];
            on-click = "${pkgs.pavucontrol}/bin/pavucontrol --tab=3";
          };
          "battery" = {
            format = "{icon} {capacity}%";
            format-charging = " {capacity}%";
            format-icons = [ "" "" "" "" "" ];
            tooltip = false;
          };
        }];
        style = ''
          * {
              font-family: FontAwesome, Iosevka, Roboto, Helvetica, Arial, sans-serif;
              font-size: 13px;
          }

          window#waybar {
              background: transparent;
              color: #000000;
          }

          button {
              border: none;
              border-radius: 0;
          }

          #workspaces button {
             border-bottom: 1px solid transparent;
          }

          #workspaces button.active {
              border-bottom: 1px solid #B6A6A0;
          }

          #workspaces button:hover {
              background: rgba(0, 0, 0, 0.2);
          }

          #workspaces button.urgent {
              background-color: #eb4d4b;
          }

          #clock,
          #battery,
          #cpu,
          #memory,
          #disk,
          #temperature,
          #backlight,
          #network,
          #pulseaudio,
          #wireplumber,
          #custom-media,
          #tray,
          #mode,
          #idle_inhibitor,
          #scratchpad,
          #mpd {
              padding: 0 10px;
              color: #000000;
              background: transparent;
          }

          /* If workspaces is the leftmost module, omit left margin */
          .modules-left > widget:first-child > #workspaces {
              margin-left: 0;
          }

          /* If workspaces is the rightmost module, omit right margin */
          .modules-right > widget:last-child > #workspaces {
              margin-right: 0;
          }
        '';
      };
    };
  };
}
