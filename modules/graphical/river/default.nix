{ config, lib, pkgs, ... }:

let
  river-init = pkgs.writeShellScript "river-init" ''
    riverctl map normal Super Return spawn kitty
    riverctl map normal Super D spawn ${pkgs.fuzzel}/bin/fuzzel

    riverctl map normal Super     C spawn "otd applypreset nav"
    riverctl map normal Super+Alt C spawn "otd applypreset absolute"

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
      riverctl map normal Super+Shift   $i set-view-tags       $tags
      riverctl map normal Super+Control $i toggle-focused-tags $tags
      riverctl map normal Super+Shift+Control $i toggle-view-tags $tags
    done

    riverctl map normal Super Up    send-layout-cmd rivertile "main-location top"
    riverctl map normal Super Right send-layout-cmd rivertile "main-location right"
    riverctl map normal Super Down  send-layout-cmd rivertile "main-location bottom"
    riverctl map normal Super Left  send-layout-cmd rivertile "main-location left"

    riverctl map normal None XF86AudioRaiseVolume  spawn '${pkgs.pamixer}/bin/pamixer -i 5'
    riverctl map normal None XF86AudioLowerVolume  spawn '${pkgs.pamixer}/bin/pamixer -d 5'
    riverctl map normal None XF86AudioMute         spawn '${pkgs.pamixer}/bin/pamixer --toggle-mute'
    riverctl map normal None XF86MonBrightnessDown spawn '${pkgs.brightnessctl}/bin/brightnessctl s -- -5%'
    riverctl map normal None XF86MonBrightnessUp   spawn '${pkgs.brightnessctl}/bin/brightnessctl s -- +5%'

    riverctl border-width 4
    riverctl default-layout rivertile
    pkill rivertile; rivertile -view-padding 0 -outer-padding 0 &

    pkill river-tag-overl; ${pkgs.river-tag-overlay}/bin/river-tag-overlay --timeout 300 &

    ${pkgs.dbus}/bin/dbus-update-activation-environment --systemd \
      DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE XCURSOR_SIZE QT_QPA_PLATFORM_THEME QT_STYLE_OVERRIDE QT_PLUGIN_PATH QTWEBKIT_PLUGIN_PATH
  '';
  river-wrapper = pkgs.writeShellScriptBin "river" ''
    export XDG_SESSION_TYPE=wayland
    export XDG_CURRENT_DESKTOP=river
    export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
    export QT_AUTO_SCREEN_SCALE_FACTOR=0
    export QT_SCALE_FACTOR=1
    export GDK_SCALE=1
    export GDK_DPI_SCALE=1
    export MOZ_ENABLE_WAYLAND=1
    export XCURSOR_SIZE=24
    export _JAVA_AWT_WM_NONREPARENTING=1
    if [ "$DBUS_SESSION_BUS_ADDRESS" ]; then
        export DBUS_SESSION_BUS_ADDRESS
        exec ${pkgs.river}/bin/river
    else
        exec ${pkgs.dbus}/bin/dbus-run-session ${pkgs.river}/bin/river
    fi
  '';
  river = pkgs.symlinkJoin {
    name = "river-${pkgs.river.version}";
    paths = [ river-wrapper pkgs.river ];
    strictDeps = false;
    nativeBuildInputs = with pkgs; [ makeWrapper wrapGAppsHook ];
    buildInputs = with pkgs; [ gdk-pixbuf glib gtk3 ];
    dontWrapGApps = true;
    postBuild = ''
      gappsWrapperArgsHook

      wrapProgram $out/bin/river "''${gappsWrapperArgs[@]}"
    '';
  };
in
{
  options.hakanssn.graphical.river = {
    enable = lib.mkEnableOption "River window manager environment";
  };

  config = lib.mkIf config.hakanssn.graphical.river.enable {
    services = {
      dbus.packages = with pkgs; [ dconf ];
      greetd = {
        enable = true;
        settings =
          let
            river-run = pkgs.writeShellScript "river-run" ''
              exec zsh -c "systemd-cat -t river ${river}/bin/river"
            '';
          in
          {
            default_session = {
              command = "${pkgs.greetd.greetd}/bin/agreety --cmd ${river-run}";
            };
            initial_session = {
              command = "${river-run}";
              user = "hakanssn";
            };
          };
      };
    };
    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk pkgs.xdg-desktop-portal-wlr ];
    };
    home-manager.users.hakanssn = { pkgs, ... }: {
      home.packages = [
        river
        pkgs.wf-recorder
        pkgs.wl-clipboard
      ];
      services = {
        mako = {
          enable = true;
        };
      };
      xdg.configFile."river/init" = {
        source = river-init;
        onChange = ''
          if [ -d /run/user/$UID ]
          then
            WAYLAND_DISPLAY="$(${pkgs.findutils}/bin/find /run/user/$UID -mindepth 1 -maxdepth 1 -type s -name wayland-\*)"
            if [ -S "WAYLAND_DISPLAY" ]
            then
              ${river-init}
            fi
          fi
        '';
      };
    };
  };
}
