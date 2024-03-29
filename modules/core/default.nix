{ config, lib, pkgs, ... }:

{
  imports = [
    ./emacs
    ./gpg
    ./mail
    ./network
    ./nix
    ./smartd
    ./ssh
    ./sshd
    ./tmux
    ./vim
    ./zfs
    ./zsh
  ];

  options.hakanssn = {
    stateVersion = lib.mkOption { example = "21.11"; };

    dataPrefix = lib.mkOption { example = "/data"; };

    cachePrefix = lib.mkOption { example = "/cache"; };
  };

  config = {
    home-manager.useGlobalPkgs = true;

    system = {
      stateVersion = config.hakanssn.stateVersion;
      autoUpgrade = {
        enable = lib.mkDefault true;
        flake = "github:AntonHakansson/nixos-config";
        dates = "01/4:00";
        randomizedDelaySec = "10min";
      };
    };
    home-manager.users = {
      hakanssn = { ... }: {
        home.stateVersion = config.hakanssn.stateVersion;
        systemd.user.sessionVariables =
          config.home-manager.users.hakanssn.home.sessionVariables;
      };
      root = { ... }: { home.stateVersion = config.hakanssn.stateVersion; };
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
      util-linux
      whois
      wget
      curl
      unzip
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
      polkit.enable = true;
    };

    # daemon allowing you to update some devices' firmware
    services.fwupd.enable = true;

    time.timeZone = lib.mkDefault "Europe/Stockholm";

    users = {
      mutableUsers = false;
      defaultUserShell = pkgs.zsh;
      users = {
        hakanssn = {
          isNormalUser = true;
          home = "/home/hakanssn";
          description = "Anton Hakansson";
          extraGroups = [ "systemd-journal" ];
          hashedPasswordFile = config.age.secrets."passwords/users/hakanssn".path;
        };
        root.hashedPasswordFile = config.age.secrets."passwords/users/root".path;
      };
    };
    age.secrets."passwords/users/hakanssn".file =
      ../../secrets/passwords/users/hakanssn.age;
    age.secrets."passwords/users/root".file =
      ../../secrets/passwords/users/root.age;

    # tldr cache
    hakanssn.core.zfs.homeCacheLinks = [ ".cache/tealdeer" ];
  };
}
