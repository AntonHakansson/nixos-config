{ config, lib, pkgs, ... }:
{
  options.hakanssn.graphical.niri = {
    enable = lib.mkEnableOption "Niri window manager environment";
  };

  config = lib.mkIf config.hakanssn.graphical.niri.enable {
    services = {
      dbus.packages = with pkgs; [ dconf ];
    };
    programs = {
      niri.enable = true;
    };
    home-manager.users.hakanssn = { pkgs, ... }: {
      home.packages = [
        pkgs.wf-recorder
        pkgs.wl-clipboard
        pkgs.xwayland-satellite
      ];
      programs = {
        tofi.enable = true; # dmenu
      };
      services = {
        mako.enable = true; # notifications
      };
      xdg.configFile."niri/config.kdl".text = ''
        // Check the wiki for a full description of the configuration:
        // https://github.com/YaLTeR/niri/wiki/Configuration:-Introduction
        input {
            keyboard {
                xkb {
                    // For more information, see xkeyboard-config(7).
                    layout "us"
                    options "ctrl:nocaps"
                }
                numlock
            }
            touchpad {
                // off
                tap
                // dwt
                // dwtp
                // drag false
                // drag-lock
                natural-scroll
                // accel-speed 0.2
                // accel-profile "flat"
                // scroll-method "two-finger"
                // disabled-on-external-mouse
            }
            mouse {
                // off
                // natural-scroll
                // accel-speed 0.2
                // accel-profile "flat"
                // scroll-method "no-scroll"
            }
            trackpoint {
                // off
                // natural-scroll
                // accel-speed 0.2
                // accel-profile "flat"
                // scroll-method "on-button-down"
                // scroll-button 273
                // middle-emulation
            }
            warp-mouse-to-focus

            // Focus windows and outputs automatically when moving the mouse into them.
            // Setting max-scroll-amount="0%" makes it work only on windows already fully on screen.
            focus-follows-mouse max-scroll-amount="0%"
        }
        layout {
            // Set gaps around windows in logical pixels.
            gaps 16

            // When to center a column when changing focus, options are:
            // - "never", default behavior, focusing an off-screen column will keep at the left
            //   or right edge of the screen.
            // - "always", the focused column will always be centered.
            // - "on-overflow", focusing a column will center it if it doesn't fit
            //   together with the previously focused column.
            center-focused-column "never"
            always-center-single-column

            preset-column-widths {
                proportion 0.33333
                proportion 0.5
                proportion 0.66667
            }

            // Let windows decide their initial width.
            default-column-width {}
            // default-column-width { proportion 0.5; }

            focus-ring {
                width 4
                active-color "#7fc8ff"
                inactive-color "#505050"
            }
        }
        cursor {
            hide-when-typing
            hide-after-inactive-ms 1000
        }
        animations {
            slowdown 0.1
        }

        // The path is formatted with strftime(3) to give you the screenshot date and time.
        screenshot-path "~/pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png"

        // Open the Firefox picture-in-picture player as floating by default.
        window-rule {
            // This app-id regular expression will work for both:
            // - host Firefox (app-id is "firefox")
            // - Flatpak Firefox (app-id is "org.mozilla.firefox")
            match app-id=r#"firefox$"# title="^Picture-in-Picture$"
            open-floating true
        }

        binds {
            // Most actions that you can bind here can also be invoked programmatically with
            // `niri msg action do-something`.

            Mod+Shift+Slash { show-hotkey-overlay; }
            Mod+O repeat=false { toggle-overview; }

            // Binds for running terminal, app launcher, screen locker.
            Mod+T hotkey-overlay-title="Open a Terminal: kitty" { spawn "kitty"; }
            Mod+D hotkey-overlay-title="Run an Application: tofi" { spawn "bash" "-c" "$(tofi-drun)"; }
            Super+Alt+L hotkey-overlay-title="Lock the Screen: swaylock" { spawn "swaylock"; }

            // Example volume keys mappings for PipeWire & WirePlumber.
            // The allow-when-locked=true property makes them work even when the session is locked.
            XF86AudioRaiseVolume allow-when-locked=true { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1+"; }
            XF86AudioLowerVolume allow-when-locked=true { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1-"; }
            XF86AudioMute        allow-when-locked=true { spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle"; }
            XF86AudioMicMute     allow-when-locked=true { spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle"; }

            Mod+Q { close-window; }

            Mod+Left  { focus-column-left; }
            Mod+Down  { focus-window-down; }
            Mod+Up    { focus-window-up; }
            Mod+Right { focus-column-right; }
            Mod+N     { focus-column-left; }
            Mod+E     { focus-window-down; }
            Mod+U     { focus-window-up; }
            Mod+I     { focus-column-right; }

            Mod+Ctrl+Left  { move-column-left; }
            Mod+Ctrl+Down  { move-window-down; }
            Mod+Ctrl+Up    { move-window-up; }
            Mod+Ctrl+Right { move-column-right; }
            Mod+Ctrl+N     { move-column-left; }
            Mod+Ctrl+E     { move-window-down; }
            Mod+Ctrl+U     { move-window-up; }
            Mod+Ctrl+I     { move-column-right; }

            Mod+Home { focus-column-first; }
            Mod+End  { focus-column-last; }
            Mod+Ctrl+Home { move-column-to-first; }
            Mod+Ctrl+End  { move-column-to-last; }

            Mod+Shift+Left  { focus-monitor-left; }
            Mod+Shift+Down  { focus-monitor-down; }
            Mod+Shift+Up    { focus-monitor-up; }
            Mod+Shift+Right { focus-monitor-right; }
            Mod+Shift+N     { focus-monitor-left; }
            Mod+Shift+E     { focus-monitor-down; }
            Mod+Shift+U     { focus-monitor-up; }
            Mod+Shift+I     { focus-monitor-right; }

            Mod+Shift+Ctrl+Left  { move-column-to-monitor-left; }
            Mod+Shift+Ctrl+Down  { move-column-to-monitor-down; }
            Mod+Shift+Ctrl+Up    { move-column-to-monitor-up; }
            Mod+Shift+Ctrl+Right { move-column-to-monitor-right; }
            Mod+Shift+Ctrl+N     { move-column-to-monitor-left; }
            Mod+Shift+Ctrl+E     { move-column-to-monitor-down; }
            Mod+Shift+Ctrl+U     { move-column-to-monitor-up; }
            Mod+Shift+Ctrl+I     { move-column-to-monitor-right; }

            Mod+Page_Down      { focus-workspace-down; }
            Mod+Page_Up        { focus-workspace-up; }
            Mod+L              { focus-workspace-down; }
            Mod+Y              { focus-workspace-up; }
            Mod+Ctrl+Page_Down { move-column-to-workspace-down; }
            Mod+Ctrl+Page_Up   { move-column-to-workspace-up; }
            Mod+Ctrl+L         { move-column-to-workspace-down; }
            Mod+Ctrl+Y         { move-column-to-workspace-up; }

            Mod+Shift+Page_Down { move-workspace-down; }
            Mod+Shift+Page_Up   { move-workspace-up; }
            Mod+Shift+L         { move-workspace-down; }
            Mod+Shift+Y         { move-workspace-up; }

            Mod+WheelScrollDown      cooldown-ms=150 { focus-workspace-down; }
            Mod+WheelScrollUp        cooldown-ms=150 { focus-workspace-up; }
            Mod+Ctrl+WheelScrollDown cooldown-ms=150 { move-column-to-workspace-down; }
            Mod+Ctrl+WheelScrollUp   cooldown-ms=150 { move-column-to-workspace-up; }

            Mod+WheelScrollRight      { focus-column-right; }
            Mod+WheelScrollLeft       { focus-column-left; }
            Mod+Ctrl+WheelScrollRight { move-column-right; }
            Mod+Ctrl+WheelScrollLeft  { move-column-left; }

            Mod+Shift+WheelScrollDown      { focus-column-right; }
            Mod+Shift+WheelScrollUp        { focus-column-left; }
            Mod+Ctrl+Shift+WheelScrollDown { move-column-right; }
            Mod+Ctrl+Shift+WheelScrollUp   { move-column-left; }

            Mod+1 { focus-workspace 1; }
            Mod+2 { focus-workspace 2; }
            Mod+3 { focus-workspace 3; }
            Mod+4 { focus-workspace 4; }
            Mod+5 { focus-workspace 5; }
            Mod+6 { focus-workspace 6; }
            Mod+7 { focus-workspace 7; }
            Mod+8 { focus-workspace 8; }
            Mod+9 { focus-workspace 9; }
            Mod+Ctrl+1 { move-column-to-workspace 1; }
            Mod+Ctrl+2 { move-column-to-workspace 2; }
            Mod+Ctrl+3 { move-column-to-workspace 3; }
            Mod+Ctrl+4 { move-column-to-workspace 4; }
            Mod+Ctrl+5 { move-column-to-workspace 5; }
            Mod+Ctrl+6 { move-column-to-workspace 6; }
            Mod+Ctrl+7 { move-column-to-workspace 7; }
            Mod+Ctrl+8 { move-column-to-workspace 8; }
            Mod+Ctrl+9 { move-column-to-workspace 9; }

            Mod+BracketLeft  { consume-or-expel-window-left; }
            Mod+BracketRight { consume-or-expel-window-right; }
            Mod+Comma  { consume-window-into-column; }
            Mod+Period { expel-window-from-column; }

            Mod+R { switch-preset-column-width; }
            Mod+Shift+R { switch-preset-window-height; }
            Mod+Ctrl+R { reset-window-height; }
            Mod+F { maximize-column; }
            Mod+Shift+F { fullscreen-window; }

            // Expand the focused column to space not taken up by other fully visible columns.
            // Makes the column "fill the rest of the space".
            Mod+Ctrl+F { expand-column-to-available-width; }

            Mod+C { center-column; }

            // Center all fully visible columns on screen.
            Mod+Ctrl+C { center-visible-columns; }

            // * set width in pixels: "1000"
            // * adjust width in pixels: "-5" or "+5"
            // * set width as a percentage of screen width: "25%"
            // * adjust width as a percentage of screen width: "-10%" or "+10%"
            Mod+Minus { set-column-width "-10%"; }
            Mod+Equal { set-column-width "+10%"; }
            Mod+Shift+Minus { set-window-height "-10%"; }
            Mod+Shift+Equal { set-window-height "+10%"; }

            // Move the focused window between the floating and the tiling layout.
            Mod+V       { toggle-window-floating; }
            Mod+Shift+V { switch-focus-between-floating-and-tiling; }

            // Toggle tabbed column display mode.
            Mod+W { toggle-column-tabbed-display; }

            Print { screenshot; }
            Ctrl+Print { screenshot-screen; }
            Alt+Print { screenshot-window; }

            // Applications such as remote-desktop clients and software KVM switches may
            // request that niri stops processing the keyboard shortcuts defined here
            // so they may, for example, forward the key presses as-is to a remote machine.
            // It's a good idea to bind an escape hatch to toggle the inhibitor,
            // so a buggy application can't hold your session hostage.
            //
            // The allow-inhibiting=false property can be applied to other binds as well,
            // which ensures niri always processes them, even when an inhibitor is active.
            Mod+Escape allow-inhibiting=false { toggle-keyboard-shortcuts-inhibit; }

            // The quit action will show a confirmation dialog to avoid accidental exits.
            Ctrl+Alt+Delete { quit; }

            // Powers off the monitors. To turn them back on, do any input like
            // moving the mouse or pressing any other key.
            Mod+Shift+P { power-off-monitors; }
        }
      '';
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
