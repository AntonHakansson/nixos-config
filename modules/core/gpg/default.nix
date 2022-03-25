{ config, lib, pkgs, ... }:

{
  config =
    let pinentryFlavor = if config.asdf.graphical.enable then "gtk2" else "tty";
    in {
      asdf.core.zfs.homeLinks = [{
        path = ".gnupg";
        type = "data";
      }];

      programs.gnupg.agent = {
        enable = true;
        pinentryFlavor = pinentryFlavor;
      };
      home-manager.users.hakanssn = { lib, ... }: {
        home.activation.fixPermissionsCommands =
          lib.hm.dag.entryAfter [ "writeBoundary" ] ''
            $DRY_RUN_CMD chmod u=rwX,go= /home/hakanssn/.gnupg
          '';
        programs.gpg.enable = true;
        services.gpg-agent = {
          enable = true;
          defaultCacheTtl = 7200;
          maxCacheTtl = 99999;
          pinentryFlavor = pinentryFlavor;
        };
      };
    };
}
