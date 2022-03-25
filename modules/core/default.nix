{ config, lib, pkgs, ... }:

{
  imports = [ ./emacs ./gpg ./nix ./ssh ./sshd ./tmux ./vim ./zfs ./zsh ];

  options.asdf = {
    stateVersion = lib.mkOption { example = "21.11"; };

    dataPrefix = lib.mkOption { example = "/data"; };

    cachePrefix = lib.mkOption { example = "/cache"; };
  };

  config = {
    home-manager.useGlobalPkgs = true;

    system = {
      stateVersion = config.asdf.stateVersion;
      # TODO
      # autoUpgrade = {
      #   enable = true;
      #   flake = "github:AntonHakansson/nixos-config";
      #   dates = "01/4:00";
      #   randomizedDelaySec = "10min";
      # };
    };
    home-manager.users = {
      hakanssn = { ... }: { home.stateVersion = config.asdf.stateVersion; };
      root = { ... }: { home.stateVersion = config.asdf.stateVersion; };
    };

    environment.systemPackages = with pkgs; [
      binutils
      bottom
      coreutils
      curl
      direnv
      dnsutils
      dosfstools
      fd
      fzf
      git
      gptfdisk
      iputils
      jq
      lshw
      manix
      moreutils
      nix-index
      nmap
      ripgrep
      skim
      tealdeer
      tldr
      usbutils
      utillinux
      whois
    ];

    security = {
      sudo.enable = false;
      doas = {
        enable = true;
        extraRules = [{
          users = [ "hakanssn" ];
          noPass = true;
        }];
      };
    };

    # daemon allowing you to update some devices' firmware
    services.fwupd.enable = true;

    time.timeZone = lib.mkDefault "Europe/Stockholm";
    i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";

    users = {
      mutableUsers = false;
      defaultUserShell = pkgs.zsh;
      users = {
        hakanssn = {
          isNormalUser = true;
          home = "/home/hakanssn";
          description = "Anton Hakansson";
          extraGroups = [ "systemd-journal" ];
          passwordFile = config.age.secrets."passwords/users/hakanssn".path;
        };
        root.passwordFile = config.age.secrets."passwords/users/root".path;
      };
    };
    age.secrets."passwords/users/hakanssn".file = ../../secrets/passwords/users/hakanssn.age;
    age.secrets."passwords/users/root".file = ../../secrets/passwords/users/root.age;

    # tldr cache
    asdf.core.zfs.homeLinks = [{
      path = ".cache/tealdeer";
      type = "cache";
    }];
  };
}
