{ config, lib, pkgs, ... }:
{
  options.hakanssn.graphical.river = {
    enable = lib.mkEnableOption "River window manager environment";
  };

  config = lib.mkIf config.hakanssn.graphical.river.enable {
    services = {
      dbus.packages = with pkgs; [ dconf ];
    };
    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk pkgs.xdg-desktop-portal-wlr ];
      config.preferred = {
        default = "gtk";
        "org.freedesktop.impl.portal.Screencast" = "wlr";
      };
    };
    home-manager.users.hakanssn = { pkgs, ... }: {
      home.packages = [
        pkgs.wf-recorder
        pkgs.wl-clipboard
      ];
      programs = {
        tofi.enable = true; # dmenu
      };
      services = {
        mako.enable = true; # notifications
        wob.enable = true;  # overlay bar for volume
        cliphist.enable = true;  # clipboard history
      };
      wayland.windowManager.river = {
        enable = true;
        extraSessionVariables = {
          "QT_WAYLAND_DISABLE_WINDOWDECORATION" = "1";
          "MOZ_ENABLE_WAYLAND" = "1";
          "_JAVA_AWT_WM_NONREPARENTING" = "1";
        };
        extraConfig = ''
              riverctl map normal Super Return spawn kitty
              riverctl map normal Super D      spawn "\$(tofi-drun)"

              riverctl map normal Super Q close
              riverctl map normal Super Space zoom
              riverctl map normal Super F toggle-fullscreen
              riverctl map normal Super V toggle-float

              riverctl map normal Super N focus-view next
              riverctl map normal Super E focus-view previous

              riverctl map normal Super+Shift N swap next
              riverctl map normal Super+Shift E swap previous

              riverctl map normal Super+Alt M move left  100
              riverctl map normal Super+Alt N move down  100
              riverctl map normal Super+Alt E move up    100
              riverctl map normal Super+Alt I move right 100

              riverctl map normal Super+Alt+Control M snap left
              riverctl map normal Super+Alt+Control N snap down
              riverctl map normal Super+Alt+Control E snap up
              riverctl map normal Super+Alt+Control I snap right

              riverctl map normal Super+Alt+Shift M resize horizontal -100
              riverctl map normal Super+Alt+Shift N resize vertical    100
              riverctl map normal Super+Alt+Shift E resize vertical   -100
              riverctl map normal Super+Alt+Shift I resize horizontal  100

              riverctl map-pointer normal Super BTN_LEFT  move-view
              riverctl map-pointer normal Super BTN_RIGHT resize-view

              for i in $(seq 1 9)
              do
                tags=$((1 << ($i - 1)))
                riverctl map normal Super         $i set-focused-tags    $tags
                riverctl map normal Super+Shift   $i toggle-focused-tags $tags
                riverctl map normal Super+Control $i set-view-tags       $tags
                riverctl map normal Super+Control+Shift $i toggle-view-tags $tags
              done

              riverctl map normal Super Up    send-layout-cmd rivertile "main-location top"
              riverctl map normal Super Right send-layout-cmd rivertile "main-location right"
              riverctl map normal Super Down  send-layout-cmd rivertile "main-location bottom"
              riverctl map normal Super Left  send-layout-cmd rivertile "main-location left"

              riverctl map normal None XF86AudioRaiseVolume  spawn '${pkgs.pamixer}/bin/pamixer -i 5 &&
                                                                      ${pkgs.pamixer}/bin/pamixer --get-volume > $XDG_RUNTIME_DIR/wob.sock'
              riverctl map normal None XF86AudioLowerVolume  spawn '${pkgs.pamixer}/bin/pamixer -d 5 &&
                                                                      ${pkgs.pamixer}/bin/pamixer --get-volume > $XDG_RUNTIME_DIR/wob.sock'
              riverctl map normal None XF86AudioMute         spawn '${pkgs.pamixer}/bin/pamixer --toggle-mute &&
                                                                      ( [ "$(${pkgs.pamixer}/bin/pamixer --get-mute)" = "true" ] && echo 0 > $XDG_RUNTIME_DIR/wob.sock ) ||
                                                                      ${pkgs.pamixer}/bin/pamixer --get-volume > $XDG_RUNTIME_DIR/wob.sock'
              riverctl map normal None XF86MonBrightnessDown spawn '${pkgs.brightnessctl}/bin/brightnessctl s -- -5%'
              riverctl map normal None XF86MonBrightnessUp   spawn '${pkgs.brightnessctl}/bin/brightnessctl s -- +5%'

              riverctl border-width 8
              riverctl default-layout rivertile
              pkill rivertile; rivertile -view-padding 0 -outer-padding 0 &

              pkill river-tag-overl; ${pkgs.river-tag-overlay}/bin/river-tag-overlay --timeout 300 &
          ''
        + (lib.optionalString config.home-manager.users.hakanssn.services.cliphist.enable ''
            riverctl map normal Super O spawn "cliphist list | tofi | cliphist decode | wl-copy"
            pkill wl-paste; wl-paste --watch cliphist store &
        '')
        + (lib.optionalString config.hardware.opentabletdriver.enable ''
            riverctl map normal Super     C spawn "otd applypreset nav"
            riverctl map normal Super+Alt C spawn "otd applypreset absolute"
         '');
      };
      # ref: https://codeberg.org/river/wiki#user-content-how-do-i-disable-gtk-decorations-e-g-title-bar
      xdg.configFile."gtk-3.0/gtk.css".text = ''
        /* No (default) title bar on wayland */
        headerbar.default-decoration {
          margin-bottom: 50px;
          margin-top: -100px;
        }
        /* rm -rf window shadows */
        window.csd,
        window.csd decoration {
          box-shadow: none;
        }
      '';
    };
  };
}
