{ config, lib, pkgs, ... }:

{
  options.hakanssn.graphical.syncthing.enable = lib.mkEnableOption "syncthing";

  config = lib.mkIf config.hakanssn.graphical.syncthing.enable {
    hakanssn.core.zfs.homeDataLinks = [ ".config/syncthing" ];

    home-manager.users.hakanssn = { pkgs, ... }: {
      services.syncthing = {
        enable = true;
        extraOptions = [ "--no-default-folder" ];
      };
    };
  };
}
