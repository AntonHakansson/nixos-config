{ config, lib, pkgs, ... }: {
  options.hakanssn.core.zfs = {
    encrypted = lib.mkEnableOption "zfs request credentials";

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
    hakanssn.dataPrefix = lib.mkDefault "/data";
    hakanssn.cachePrefix = lib.mkDefault "/cache";

    environment.persistence."${config.hakanssn.cachePrefix}" = {
      hideMounts = true;
      directories = config.hakanssn.core.zfs.systemCacheLinks;
      users.hakanssn.directories = config.hakanssn.core.zfs.homeCacheLinks;
    };
    environment.persistence."${config.hakanssn.dataPrefix}" = {
      hideMounts = true;
      directories = config.hakanssn.core.zfs.systemDataLinks;
      users.hakanssn.directories = config.hakanssn.core.zfs.homeDataLinks;
    };

    boot = {
      supportedFilesystems = [ "zfs" ];
      zfs = {
        devNodes = "/dev/";
        requestEncryptionCredentials = config.hakanssn.core.zfs.encrypted;
      };
      initrd.postDeviceCommands = lib.mkAfter ''
        zfs rollback -r ${config.hakanssn.core.zfs.rootDataset}@blank
      '';
    };

    services = {
      zfs = {
        autoScrub.enable = true;
        trim.enable = true;
      };
      # znapzend = {
      #   enable = config.hakanssn.core.zfs.backups != [ ];
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
      #   }) config.hakanssn.core.zfs.backups);
      # };
    };

    # Discover directories that will be removed on next boot
    environment.systemPackages = [
      (pkgs.writeScriptBin "zfsdiff" ''
        doas zfs diff ${config.hakanssn.core.zfs.rootDataset}@blank -F | ${pkgs.ripgrep}/bin/rg -e "\+\s+/\s+" | cut -f3- | ${pkgs.skim}/bin/sk --query "/home/hakanssn/"
      '')
    ];

    system.activationScripts =
      let
        ensureSystemExistsScript = lib.concatStringsSep "\n"
          (map (path: ''mkdir -p "${path}"'')
            config.hakanssn.core.zfs.ensureSystemExists);
        ensureHomeExistsScript = lib.concatStringsSep "\n" (map
          (path:
            ''
              mkdir -p "/home/hakanssn/${path}"; chown hakanssn:users /home/hakanssn/${path};'')
          config.hakanssn.core.zfs.ensureHomeExists);
      in
      {
        ensureSystemPathsExist = {
          text = ensureSystemExistsScript;
          deps = [ "agenixNewGeneration" ];
        };
        ensureHomePathsExist = {
          text = ''
            mkdir -p /home/hakanssn/
            ${ensureHomeExistsScript}
          '';
          deps = [ "users" "groups" ];
        };
        agenixInstall.deps = [ "ensureSystemPathsExist" "ensureHomePathsExist" ];
      };
  };
}
