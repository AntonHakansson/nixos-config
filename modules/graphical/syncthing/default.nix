{ config, lib, pkgs, ... }:

{
  options.asdf.graphical.syncthing.enable = lib.mkEnableOption "syncthing";

  config = lib.mkIf config.asdf.graphical.syncthing.enable {
    asdf.core.zfs.homeDataLinks = [ ".config/syncthing" ];

    home-manager.users.hakanssn = { pkgs, ... }: {
      services.syncthing = {
        enable = true;
        extraOptions = [ "--no-default-folder" ];
      };
    };
  };
}
