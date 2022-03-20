{ config, lib, pkgs, ... }:

{
  config = {
    asdf.core.zfs.homeLinks = [{
      path = ".gnupg";
      type = "data";
    }];

    programs.gnupg.agent = {
      enable = true;
      pinentryFlavor = "gtk2";
    };
    home-manager.users.hakanssn = { lib, ... }: {
      home.activation.fixPermissionsCommands =
        lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          chmod u=rwX,go= /home/hakanssn/.gnupg
        '';
      programs.gpg.enable = true;
      services.gpg-agent = {
        enable = true;
        enableSshSupport = true;
        defaultCacheTtl = 7200;
        maxCacheTtl = 99999;
        pinentryFlavor = "gtk2";

        # gpg --list-keys --with-keygrip
        sshKeys = [ "789306B940E996B597D9D458942718C7E73B3A5F" ];
      };
    };
  };
}
