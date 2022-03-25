{ config, lib, pkgs, ... }: {
  options.asdf.core.zfs = {
    encrypted = lib.mkOption {
      default = false;
      example = true;
    };

    systemCacheLinks = lib.mkOption { default = [ ]; };
    systemDataLinks = lib.mkOption { default = [ ]; };
    homeCacheLinks = lib.mkOption { default = [ ]; };
    homeDataLinks = lib.mkOption { default = [ ]; };

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

    environment.persistence."${config.asdf.cachePrefix}" = {
      hideMounts = true;
      directories = config.asdf.core.zfs.systemCacheLinks;
      users.hakanssn.directories = config.asdf.core.zfs.homeCacheLinks;
    };
    environment.persistence."${config.asdf.dataPrefix}" = {
      hideMounts = true;
      directories = config.asdf.core.zfs.systemDataLinks;
      users.hakanssn.directories = config.asdf.core.zfs.homeDataLinks;
    };

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
        deps = [ "agenixMountSecrets" ];
      };
      agenixRoot.deps = [ "ensureSystemPathsExist" ];

      ensureHomePathsExist = {
        text = ''
          mkdir -p /home/hakanssn/
          ${ensureHomeExistsScript}
        '';
        deps = [ "users" "groups" ];
      };
      agenix.deps = [ "ensureHomePathsExist" ];
    };
  };
}
