{ config, lib, pkgs, ... }:

{
  options.asdf.graphical.syncthing.enable = lib.mkEnableOption "syncthing";

  config = lib.mkIf config.asdf.graphical.syncthing.enable {
    asdf.core.zfs.homeDataLinks = [ ".config/syncthing" ];
    asdf.core.zfs.homeCacheLinks = [ "sync" ];

    home-manager.users.hakanssn = { pkgs, ... }: {
      services.syncthing.enable = true;
    };
  };
}
