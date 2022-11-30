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
        [ pkgs.xdg-desktop-portal-gtk pkgs.xdg-desktop-portal-wlr ];
    };

    home-manager.users.hakanssn = { pkgs, ... }: {
      home.packages = with pkgs; [ wf-recorder wl-clipboard ];
      programs = {
        mako = {
          enable = true;
          font = "Fira Code Normal 9";
        };
      };
      wayland.windowManager.hyprland = {
        enable = true;
        extraConfig = ''
          # See https://wiki.hyprland.org/Configuring/Monitors/
          monitor=,preferred,auto,1

          # See https://wiki.hyprland.org/Configuring/Keywords/ for more

          # Execute your favorite apps at launch
          # exec-once = waybar & hyprpaper & firefox

          # Source a file (multi-file configs)
          # source = ~/.config/hypr/myColors.conf

          # For all categories, see https://wiki.hyprland.org/Configuring/Variables/
          input {
              kb_layout = us
              kb_variant = altgr-intl
              kb_model =
              kb_options =
              kb_rules =

              follow_mouse = 1

              touchpad {
                  natural_scroll = no
              }

              sensitivity = 0 # -1.0 - 1.0, 0 means no modification.
              accel_profile = adaptive
          }

          general {
              # See https://wiki.hyprland.org/Configuring/Variables/ for more

              gaps_in = 5
              gaps_out = 6
              border_size = 0
              col.active_border = rgb(505050)
              col.inactive_border = rgb(efefef)

              layout = master
          }

          decoration {
              # See https://wiki.hyprland.org/Configuring/Variables/ for more

              rounding = 0
              blur = no
              # blur_size = 3
              # blur_passes = 1
              # blur_new_optimizations = on

              drop_shadow = yes
              shadow_range = 4
              shadow_render_power = 3
              col.shadow = rgba(1a1a1aee)

              dim_inactive = true
              dim_strength = 0.1
          }

          animations {
              enabled = yes

              # Some default animations, see https://wiki.hyprland.org/Configuring/Animations/ for more

              # bezier = myBezier, 0.05, 0.9, 0.1, 1.05

              # animation = windows, 1, 7, myBezier
              # animation = windowsOut, 1, 7, default, popin 80%
              # animation = border, 1, 10, default
              # animation = fade, 1, 7, default
              # animation = workspaces, 1, 6, default
          }

          dwindle {
              # See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
              pseudotile = yes # master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
              preserve_split = yes # you probably want this
          }

          master {
              # See https://wiki.hyprland.org/Configuring/Master-Layout/ for more
              new_is_master = true
          }

          gestures {
              # See https://wiki.hyprland.org/Configuring/Variables/ for more
              workspace_swipe = off
          }

          misc {
               disable_hyprland_logo = true
               disable_splash_rendering = true
               enable_swallow = true
               swallow_regex = ^(kitty)$
          }

          # Example per-device config
          # See https://wiki.hyprland.org/Configuring/Keywords/#executing for more
          device:epic mouse V1 {
              sensitivity = -0.5
          }

          # Example windowrule v1
          # windowrule = float, ^(kitty)$
          # Example windowrule v2
          # windowrulev2 = float,class:^(kitty)$,title:^(kitty)$
          # See https://wiki.hyprland.org/Configuring/Window-Rules/ for more


          # Example binds, see https://wiki.hyprland.org/Configuring/Binds/ for more
          bind = SUPER, return, exec, kitty
          bind = SUPER, Q, killactive,
          bind = SUPER SHIFT, E, exec, hyprctl kill
          bind = SUPER, M, exit,
          bind = SUPER, V, togglefloating,
          bind = SUPER, D, exec, ${pkgs.kitty}/bin/kitty --class launcher -e ${./launcher.zsh}

          bind = SUPER,F,fullscreen,

          bind = SUPER,Tab,cyclenext,
          bind = SUPER,Tab,bringactivetotop,


          # Move focus with super + hjkl
          bind = SUPER, h, movefocus, l
          bind = SUPER, l, movefocus, r
          bind = SUPER, k, layoutmsg, cycleprev
          bind = SUPER, j, layoutmsg, cyclenext

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
          bind  =, XF86MonBrightnessDown,exec, ${pkgs.brightnessctl}/bin/brightnessctl set -5%"
          bind  =, XF86MonBrightnessUp,  exec, ${pkgs.brightnessctl}/bin/brightnessctl set +5%"

          # Notifications
          bind = SUPER,       N, exec, ${pkgs.mako}/bin/makoctl dismiss
          bind = SUPER SHIFT, N, exec, ${pkgs.mako}/bin/makoctl invoke;

          # Window Rules
          windowrule=float,^(launcher)$

          # Status Bar
          exec-once = waybar
          bind = SUPER, b, exec, ${pkgs.killall}/bin/killall -SIGUSR1 .waybar-wrapped
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
          modules-center = [ "clock" "clock#time" ];
          modules-right = [ "network" "pulseaudio" "custom/bluetooth" "battery" "custom/power" ];
          "clock" = {
            format = "{:%a, %d %b}";
            interval = 3600;
          };
          "clock#time" = {
            format = "{:%H:%M}";
            interval = 60;
          };
          "network" = {
            format = "";
            tooltip = false;
          };
          "pulseaudio" = {
            format = "{icon}";
            format-muted = "<span color=\"#4a4a4a\"></span>";
            format-icons = [ "" "" "" ];
            on-click = "${pkgs.pavucontrol}/bin/pavucontrol --tab=3";
            tooltip = false;
          };
          "battery" = {
            format = "{icon} {capacity}%";
            format-charging = " {capacity}%";
            format-icons = [ "" "" "" "" "" ];
            tooltip = false;
          };
        }];
        style = ''
          #waybar {
            background: transparent;
          }
          #workspaces, #workspaces button, #battery, #bluetooth, #network, #clock, #clock.time, #pulseaudio, #custom-bluetooth, #custom-power {
            font-family: "Iosevka", "FontAwesome6Free";
            color: #b0b0b0;
            background-color: #0a0a0a;
            border-radius: 0;
            transition: none;
          }
          #clock.time, #workspaces button.active {
            background-color: #b0b0b0;
            color: #0a0a0a;
          }
          #clock, #network {
            border-radius: 6px 0 0 6px;
          }
          #workspaces, #workspaces button {
            padding: 0 4px 0 4px;
            border-radius: 6px;
          }
          #workspaces button.active {
            border-radius: 50%;
            padding: 0 4px;
            margin: 4px 0 4px 0;
          }
          #network.disconnected {
            color: #4a4a4a;
          }
        '';
      };
    };
  };
}
