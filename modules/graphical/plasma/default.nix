{ config, lib, pkgs, ... }: {

  options.hakanssn.graphical.plasma = {
    enable = lib.mkEnableOption "Plasma Desktop environment";
  };

  config = lib.mkIf config.hakanssn.graphical.plasma.enable {

    services.dbus.packages = with pkgs; [ dconf ];
    xdg.portal.enable = true;
    services.displayManager.sddm = {
      enable = true;
      wayland.enable = true;
    };
    services.desktopManager.plasma6.enable = true;
    environment.plasma6.excludePackages = with pkgs.kdePackages; [
      baloo
      elisa # KDE video player
      gwenview # Image viewer
      kate
      khelpcenter
      kio-extras
      kmailtransport
      konsole
      kwallet
      kwallet-pam
      oxygen
      plasma-browser-integration
      print-manager
    ];

    # Get current settings with `nix run github:pjones/plasma-manager`
    home-manager.users.hakanssn = { pkgs, ... }: {
      programs.plasma = {
        enable = true;
        panels = [
          { # Auto-hide bottom bar
            location = "bottom";
            hiding = "autohide";
          }
        ];
        shortcuts = {
          plasmashell = {
            "manage activities" = [ ]; # Unset default Meta+Q shortcut
          };
          kwin = {
            "Expose" = "Meta+,";
            "Window Close" = "Meta+Q";
            "Window Fullscreen" = "Meta+F";
            "Window No Border" = "Meta+B";
            "Window Center" = "Meta+Space";
            "Walk Through Windows" = "Meta+N";
            "Walk Through Windows (Reverse)" = "Meta+E";
          };
          "org_kde_powerdevil"."powerProfile" = "Battery"; # Unset default Meta+B shortcut
        };

        configFile = {
          "kdeglobals"."KDE"."AnimationDurationFactor".value = 0.125; # Near-instant animations

          # Nightlight
          "kwinrc"."NightColor"."Active".value = true;
          "kwinrc"."NightColor"."Mode".value = "Times";
          "kwinrc"."NightColor"."NightTemperature".value = 2400;

          # 3x3 virtual desktop grid
          "kwinrc"."Desktops"."Number".value = 9;
          "kwinrc"."Desktops"."Rows".value = 3;
          "kwinrc"."Desktops"."Id_1".value = "6d7afb3d-3152-4464-a145-c0ca4318018d";
          "kwinrc"."Desktops"."Id_2".value = "43b8948d-8315-4cff-8e8c-8cfcf3dd1ecc";
          "kwinrc"."Desktops"."Id_3".value = "5091b76f-e2ed-4dd3-8b64-7e7cdf0535bb";
          "kwinrc"."Desktops"."Id_4".value = "7b0111c5-1fdb-4702-bf63-c24f09a9276f";
          "kwinrc"."Desktops"."Id_5".value = "b6522fa2-9c21-4af7-84af-147b006d6f34";
          "kwinrc"."Desktops"."Id_6".value = "cd2dc2ec-8f92-449a-a929-ee2036a6b891";
          "kwinrc"."Desktops"."Id_7".value = "badf4ae6-d4da-477b-90da-0faf24144dfe";
          "kwinrc"."Desktops"."Id_8".value = "fd22cc68-6df8-42bf-8d20-b776d920103b";
          "kwinrc"."Desktops"."Id_9".value = "62ee81a4-5ec9-4137-ab14-df6b1431c4f2";

          "kwinrulesrc"."General"."count".value = 1;
          "kwinrulesrc"."1"."Description".value = "Hide titlebar by default";
          "kwinrulesrc"."1"."noborder".value = true;
          "kwinrulesrc"."1"."noborderrule".value = 3;
          "kwinrulesrc"."1"."wmclass".value = ".*";
          "kwinrulesrc"."1"."wmclassmatch".value = 3;
        };
      };
    };
  };
}
