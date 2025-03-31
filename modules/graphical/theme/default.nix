{ config, lib, pkgs, ... }:

{
  options.hakanssn.graphical.theme = {
    enable = lib.mkEnableOption "hakanssn themes";
  };

  config = lib.mkIf config.hakanssn.graphical.theme.enable {
    fonts = {
      fontDir.enable = true;
      fontconfig = {
        enable = true;
        defaultFonts = {
          emoji = [ "Noto Color Emoji" ];
          monospace = [ "Iosevka" "Font Awesome 6 Free" ];
          sansSerif = [ "Iosevka Aile" "Font Awesome 6 Free" ];
          serif = [ "Iosevka Etoile" "Font Awesome 6 Free" ];
        };
      };
      packages = with pkgs; [
        iosevka
        (iosevka-bin.override { variant = "Aile"; })
        (iosevka-bin.override { variant = "Etoile"; })
        font-awesome
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-emoji
        noto-fonts-extra
      ];
    };
  };
}
