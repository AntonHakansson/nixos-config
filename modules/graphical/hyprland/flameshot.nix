{ config, lib, pkgs, ... }:

{
  options.hakanssn.graphical.flameshot.package = lib.mkOption {
    default = pkgs.flameshot.overrideAttrs (old: {
      src = pkgs.fetchFromGitHub {
        owner = "flameshot-org";
        repo = "flameshot";
        rev = "a447b3d672ef92acb98be996d58540e36db84e35";
        sha256 = "sha256-/GtSQE1tRbJAHKNERJiztq2Inpo5LhA3aZkbYtz/E8M=";
      };
      buildInputs = old.buildInputs ++ [ pkgs.libsForQt5.kguiaddons ];
      cmakeFlags = [
        "-DUSE_WAYLAND_CLIPBOARD=true"
      ];
    });
    readOnly = true;
  };

  config = lib.mkIf config.hakanssn.graphical.hyprland.enable {
    home-manager.users.hakanssn = { pkgs, ... }: {
      home.packages = with pkgs; [
        wl-clipboard
        config.hakanssn.graphical.flameshot.package
      ];
    };
  };
}
