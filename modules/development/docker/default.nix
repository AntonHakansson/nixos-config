{ config, lib, pkgs, ... }:

{
  options.asdf.development.docker.enable = lib.mkEnableOption "docker";

  config = lib.mkIf config.asdf.development.docker.enable {
    asdf.core.zfs.systemDataLinks = [ "/var/lib/docker" ];

    virtualisation.docker = {
      enable = true;
      storageDriver = "zfs";
    };

    environment.systemPackages = [ pkgs.docker-compose ];

    users.users.hakanssn.extraGroups = [ "docker" ];
  };
}
