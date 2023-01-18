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
      programs = {
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
              # See https://wiki.hyprland.org/Configuring/Variables/

              gaps_in = 5
              gaps_out = 6
              border_size = 0
              col.active_border = rgb(505050)
              col.inactive_border = rgb(efefef)

              layout = master
          }
          # background color
          exec-once = "${pkgs.swaybg}/bin/swaybg -c '#ffffff'"

          decoration {
              # See https://wiki.hyprland.org/Configuring/Variables/

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
              # See https://wiki.hyprland.org/Configuring/Animations/

              enabled = yes


              # bezier = myBezier, 0.05, 0.9, 0.1, 1.05

              # animation = windows, 1, 7, myBezier
              # animation = windowsOut, 1, 7, default, popin 80%
              # animation = border, 1, 10, default
              # animation = fade, 1, 7, default
              # animation = workspaces, 1, 6, default
          }

          dwindle {
              # See https://wiki.hyprland.org/Configuring/Dwindle-Layout/
              pseudotile = yes # master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
              preserve_split = yes # you probably want this
          }

          master {
              # See https://wiki.hyprland.org/Configuring/Master-Layout/
              new_is_master = false
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
          windowrule=float,^(launcher)$
          windowrule=float,^(kitty)$

          # Status Bar
          exec-once = waybar
          bind = SUPER, b, exec, ${pkgs.killall}/bin/killall -SIGUSR1 .waybar-wrapped

          # Keybindings
          ## See https://wiki.hyprland.org/Configuring/Binds/
          bind = SUPER, return, exec, kitty
          bind = SUPER, Q, killactive,
          bind = SUPER SHIFT, E, exec, hyprctl kill
          bind = SUPER, M, exit,
          bind = SUPER, V, togglefloating,
          bind = SUPER, T, pin,
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
          modules-right = [
            "network"
            "pulseaudio"
            "custom/bluetooth"
            "battery"
            "custom/power"
          ];
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
          * {
              font-family: FontAwesome, Roboto, Helvetica, Arial, sans-serif;
              font-size: 13px;
          }

          window#waybar {
              background: transparent;
              color: #000000;
          }

          window#waybar.hidden {
              opacity: 0.2;
          }

          button {
              border: none;
              border-radius: 0;
          }

          #workspaces button {
              background-color: #f0f0f0;
              padding: 0 5px;
          }

          #workspaces button:hover {
              background: rgba(0, 0, 0, 0.2);
          }

          #workspaces button.active {
              background-color: #d7d7d7;
          }

          #workspaces button.urgent {
              background-color: #eb4d4b;
          }

          #mode {
              background-color: #64727D;
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
              background-color: #f0f0f0;
          }

          #window,
          #workspaces {
              margin: 0 4px;
          }

          /* If workspaces is the leftmost module, omit left margin */
          .modules-left > widget:first-child > #workspaces {
              margin-left: 0;
          }

          /* If workspaces is the rightmost module, omit right margin */
          .modules-right > widget:last-child > #workspaces {
              margin-right: 0;
          }

          #clock {
          }
          #clock.time {
            background-color: #d7d7d7;
          }

          #battery {
              background-color: #000000;
          }

          #battery.charging, #battery.plugged {
              background-color: #26A65B;
          }

          @keyframes blink {
              to {
                  background-color: #000000;
                  color: #000000;
              }
          }

          #battery.critical:not(.charging) {
              background-color: #f53c3c;
              color: #000000;
              animation-name: blink;
              animation-duration: 0.5s;
              animation-timing-function: linear;
              animation-iteration-count: infinite;
              animation-direction: alternate;
          }

          label:focus {
              background-color: #000000;
          }

          #cpu {
              background-color: #2ecc71;
              color: #000000;
          }

          #memory {
              background-color: #9b59b6;
          }

          #disk {
              background-color: #964B00;
          }

          #backlight {
              background-color: #90b1b1;
          }

          #network {
              background-color: #2980b9;
          }

          #network.disconnected {
              background-color: #f53c3c;
          }

          #pulseaudio {
              background-color: #f1c40f;
              color: #000000;
          }

          #pulseaudio.muted {
              background-color: #90b1b1;
              color: #2a5c45;
          }

          #wireplumber {
              background-color: #fff0f5;
              color: #000000;
          }

          #wireplumber.muted {
              background-color: #f53c3c;
          }

          #custom-media {
              background-color: #66cc99;
              color: #2a5c45;
              min-width: 100px;
          }

          #custom-media.custom-spotify {
              background-color: #66cc99;
          }

          #custom-media.custom-vlc {
              background-color: #ffa000;
          }

          #temperature {
              background-color: #f0932b;
          }

          #temperature.critical {
              background-color: #eb4d4b;
          }

          #tray {
              background-color: #2980b9;
          }

          #tray > .passive {
              -gtk-icon-effect: dim;
          }

          #tray > .needs-attention {
              -gtk-icon-effect: highlight;
              background-color: #eb4d4b;
          }

          #idle_inhibitor {
              background-color: #2d3436;
          }

          #idle_inhibitor.activated {
              background-color: #ecf0f1;
              color: #2d3436;
          }

          #mpd {
              background-color: #66cc99;
              color: #2a5c45;
          }

          #mpd.disconnected {
              background-color: #f53c3c;
          }

          #mpd.stopped {
              background-color: #90b1b1;
          }

          #mpd.paused {
              background-color: #51a37a;
          }

          #language {
              background: #00b093;
              color: #740864;
              padding: 0 5px;
              margin: 0 5px;
              min-width: 16px;
          }

          #keyboard-state {
              background: #97e1ad;
              color: #000000;
              padding: 0 0px;
              margin: 0 5px;
              min-width: 16px;
          }

          #keyboard-state > label {
              padding: 0 5px;
          }

          #keyboard-state > label.locked {
              background: rgba(0, 0, 0, 0.2);
          }

          #scratchpad {
              background: rgba(0, 0, 0, 0.2);
          }

          #scratchpad.empty {
              background-color: transparent;
          }
        '';
      };
    };
  };
}
