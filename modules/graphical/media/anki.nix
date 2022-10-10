{ config, lib, pkgs, ... }:

{
  options.hakanssn.graphical.media.anki.enable = lib.mkEnableOption "Anki";

  config = lib.mkIf config.hakanssn.graphical.media.anki.enable {
    hakanssn.core.zfs.homeDataLinks = [ ".local/share/Anki2" ];
    home-manager.users.hakanssn = { ... }: {
      home.packages = with pkgs; [ anki ];
    };
  };
}
