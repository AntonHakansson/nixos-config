{ config, lib, pkgs, ... }:

{
  options.hakanssn.development.docker.enable = lib.mkEnableOption "docker";

  config = lib.mkIf config.hakanssn.development.docker.enable {
    hakanssn.core.zfs.systemDataLinks = [ "/var/lib/docker" ];

    virtualisation.docker = {
      enable = true;
      storageDriver = "zfs";
    };

    environment.systemPackages = [ pkgs.docker-compose ];

    users.users.hakanssn.extraGroups = [ "docker" ];
  };
}
