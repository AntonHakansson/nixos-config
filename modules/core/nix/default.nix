{ config, lib, pkgs, ... }:
let
  baseDirenv = {
    programs.direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };
  };
  baseNixIndex = {
    home.packages = with pkgs; [ nix-index ];
    programs.zsh.initExtra = ''
      source ${pkgs.nix-index}/etc/profile.d/command-not-found.sh
    '';
    systemd.user = {
      services.nix-index = {
        Unit = { Description = "Service to run nix-index"; };
        Service = {
          Type = "oneshot";
          ExecStart = "${pkgs.nix-index}/bin/nix-index";
        };
      };
      timers.nix-index = {
        Unit = {
          Description = "Timer that starts nix-index every two hours";
          PartOf = [ "nix-index.service" ];
        };
        Timer = { OnCalendar = "00/2:30"; };
        Install = { WantedBy = [ "default.target" ]; };
      };
    };
  };
in {
  options.asdf.core.nix = {
    enableDirenv = lib.mkOption {
      default = true;
      example = false;
    };
    unfreePackages = lib.mkOption {
      default = [ ];
      example = [ "teams" ];
    };
    # Note that this is only enabled for hakanssn, until https://github.com/bennofs/nix-index/issues/143 is resolved.
    enableNixIndex = lib.mkOption {
      default = true;
      example = false;
    };
  };

  config = {
    asdf.core = {
      zfs = {
        homeCacheLinks =
          (lib.optional config.asdf.core.nix.enableDirenv ".local/share/direnv")
          ++ (lib.optional config.asdf.core.nix.enableNixIndex
            ".cache/nix-index");
        systemCacheLinks =
          (lib.optional config.asdf.core.nix.enableDirenv
            "/root/.local/share/direnv");
      };
    };

    nix = {
      gc = {
        automatic = true;
        dates = "daily";
        options = "--delete-older-than 7d";
      };
      package = pkgs.nixStable;
      settings = {
        auto-optimise-store = true;
        substituters =
          [ "https://cache.nixos.org" "https://nix-community.cachix.org" ];
        trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];
        trusted-users = [ "@wheel" ];
      };
      extraOptions = lib.mkIf config.asdf.core.nix.enableDirenv ''
        keep-outputs = true
        keep-derivations = true
      '';
    };

    nixpkgs.config.allowUnfreePredicate = pkg:
      builtins.elem (lib.getName pkg) config.asdf.core.nix.unfreePackages;

    home-manager.users.hakanssn = { ... }:
      lib.recursiveUpdate
      (lib.optionalAttrs config.asdf.core.nix.enableDirenv baseDirenv)
      (lib.optionalAttrs config.asdf.core.nix.enableNixIndex baseNixIndex);
    home-manager.users.root = { ... }:
      lib.optionalAttrs config.asdf.core.nix.enableDirenv baseDirenv;
  };
}
