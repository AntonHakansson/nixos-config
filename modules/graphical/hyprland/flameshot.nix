{ config, lib, pkgs, ... }:

{
  options.hakanssn.graphical.flameshot.package = lib.mkOption {
    default = pkgs.flameshot.overrideAttrs (old: {
      src = pkgs.fetchFromGitHub {
        owner = "flameshot-org";
        repo = "flameshot";
        rev = "3d21e4967b68e9ce80fb2238857aa1bf12c7b905";
        sha256 = "sha256-OLRtF/yjHDN+sIbgilBZ6sBZ3FO6K533kFC1L2peugc=";
      };
      buildInputs = old.buildInputs ++ [ pkgs.libsForQt5.kguiaddons ];
      cmakeFlags = [
        "-DUSE_WAYLAND_CLIPBOARD=true"
        "-DUSE_WAYLAND_GRIM=true"
      ];
    });
    readOnly = true;
  };

  config = lib.mkIf config.hakanssn.graphical.hyprland.enable {
    home-manager.users.hakanssn = { pkgs, ... }: {
      home.packages = with pkgs; [
        wl-clipboard
        config.hakanssn.graphical.flameshot.package
        slurp
        grim
      ];
    };
  };
}
