{ config, lib, pkgs, ... }: {
  options.asdf.core.zfs = {
    encrypted = lib.mkOption {
      default = false;
      example = true;
    };
    systemLinks = lib.mkOption {
      default = [ ];
      example = [
        {
          path = "/var/lib/docker";
          type = "cache";
        }
        {
          path = "/var/lib/docker/volumes";
          type = "data";
        }
      ];
    };
    homeLinks = lib.mkOption {
      default = [ ];
      example = [
        {
          path = ".config/syncthing";
          type = "data";
        }
        {
          path = ".cache/nix-index";
          type = "cache";
        }
      ];
    };
    ensureSystemExists = lib.mkOption {
      default = [ ];
      example = [ "/data/etc/ssh" ];
    };
    ensureHomeExists = lib.mkOption {
      default = [ ];
      example = [ ".ssh" ];
    };
    backups = lib.mkOption {
      default = [ ];
      example = [{
        path = "rpool/safe/data";
        remotePath = "zdata/recv/<hostname>/safe/data";
        location = "vultr.hakanssn.com";
      }];
    };
    rootDataset = lib.mkOption { example = "rpool/local/root"; };
  };

  config = {
    asdf.dataPrefix = lib.mkDefault "/data";
    asdf.cachePrefix = lib.mkDefault "/cache";

    boot = {
      supportedFilesystems = [ "zfs" ];
      zfs.requestEncryptionCredentials = config.asdf.core.zfs.encrypted;
      initrd.postDeviceCommands = lib.mkAfter ''
        zfs rollback -r ${config.asdf.core.zfs.rootDataset}@blank
      '';
    };

    services = {
      zfs = {
        autoScrub.enable = true;
        trim.enable = true;
      };
      # znapzend = {
      #   enable = config.asdf.core.zfs.backups != [ ];
      #   pure = true;
      #   autoCreation = true;
      #   zetup = builtins.listToAttrs (map (elem: {
      #     name = elem.path;
      #     value = {
      #       enable = true;
      #       # <retention> => <interval>
      #       #   <retention>: how long to keep the backup
      #       #   <interval>: create new backup each interval
      #       plan =
      #         "1day=>1hour,1week=>1day,4week=>1week,1year=>1month,10year=>6month";
      #       timestampFormat = "%Y-%m-%d--%H%M%SZ";
      #       destinations."${elem.location}" = {
      #         # plan = "1day=>1hour,1week=>1day,4week=>1week,1year=>1month,10year=>6month";
      #         host = "${elem.location}";
      #         dataset = elem.remotePath;
      #       };
      #     };
      #   }) config.asdf.core.zfs.backups);
      # };
    };

    # Discover directories that will be removed on next boot
    environment.systemPackages = [
      (pkgs.writeScriptBin "zfsdiff" ''
        doas zfs diff ${config.asdf.core.zfs.rootDataset}@blank -F | ${pkgs.ripgrep}/bin/rg -e "\+\s+/\s+" | cut -f3- | ${pkgs.skim}/bin/sk --query "/home/hakanssn/"
      '')
    ];

    system.activationScripts = let
      ensureSystemExistsScript = lib.concatStringsSep "\n"
        (map (path: ''mkdir -p "${path}"'')
          config.asdf.core.zfs.ensureSystemExists);
      ensureHomeExistsScript = lib.concatStringsSep "\n" (map (path:
        ''
          mkdir -p "/home/hakanssn/${path}"; chown hakanssn:users /home/hakanssn/${path};'')
        config.asdf.core.zfs.ensureHomeExists);
    in {
      ensureSystemPathsExist = {
        text = ensureSystemExistsScript;
        # deps = [ "agenixMountSecrets" ];
      };
      # agenixRoot.deps = [ "ensureSystemPathsExist" ];

      ensureHomePathsExist = {
        text = ''
          mkdir -p /home/hakanssn/
          ${ensureHomeExistsScript}
        '';
        deps = [ "users" "groups" ];
      };
      # agenix.deps = [ "ensureHomePathsExist" ];
    };

    # NOTE: systemd-mount creates parent directories as root owner, therefore it is
    # important that we create the directories locally with the right
    # permissions.
    systemd.services = let
      makeLinkScript = config:
        lib.concatStringsSep "\n"
        (map (location: ''mkdir -p "${location.path}"'') config);
      systemLinksScript = makeLinkScript config.asdf.core.zfs.systemLinks;
      homeLinksScript = makeLinkScript config.asdf.core.zfs.homeLinks;
    in {
      make-system-links-destinations = {
        script = systemLinksScript;
        after = [ "local-fs.target" ];
        wants = [ "local-fs.target" ];
        before = [ "shutdown.target" "sysinit.target" ];
        conflicts = [ "shutdown.target" ];
        wantedBy = [ "sysinit.target" ];
        serviceConfig = {
          RemainAfterExit = "yes";
          Type = "oneshot";
          UMask = "0077";
        };
        unitConfig = { DefaultDependencies = "no"; };
      };

      make-home-links-destinations = {
        script = homeLinksScript;
        after = [ "local-fs.target" "make-system-links-destinations.service" ];
        wants = [ "local-fs.target" "make-system-links-destinations.service" ];
        before = [ "shutdown.target" "sysinit.target" ];
        conflicts = [ "shutdown.target" ];
        wantedBy = [ "sysinit.target" ];
        serviceConfig = {
          RemainAfterExit = "yes";
          Type = "oneshot";
          User = "hakanssn";
          Group = "users";
          UMask = "0077";
          WorkingDirectory = "/home/hakanssn";
        };
        unitConfig = { DefaultDependencies = "no"; };
      };
    };

    systemd.mounts = (map (location: {
      what = "/${location.type}${location.path}";
      where = "${location.path}";
      type = "none";
      options = "bind";
      after = [ "local-fs.target" "make-system-links-destinations.service" ];
      wants = [ "local-fs.target" "make-system-links-destinations.service" ];
      before = [ "umount.target" "sysinit.target" ];
      conflicts = [ "umount.target" ];
      wantedBy = [ "sysinit.target" ];
      unitConfig = { DefaultDependencies = "no"; };
    }) config.asdf.core.zfs.systemLinks) ++ (map (location: {
      what = "/${location.type}/home/hakanssn/${location.path}";
      where = "/home/hakanssn/${location.path}";
      type = "none";
      options = "bind";
      after = [ "local-fs.target" "make-home-links-destinations.service" ];
      wants = [ "local-fs.target" "make-home-links-destinations.service" ];
      before = [ "umount.target" "sysinit.target" ];
      conflicts = [ "umount.target" ];
      wantedBy = [ "sysinit.target" ];
      unitConfig = { DefaultDependencies = "no"; };
    }) config.asdf.core.zfs.homeLinks);
  };
}
